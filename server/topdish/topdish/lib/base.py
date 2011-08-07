import cgi
import time
import logging
import sqlalchemy as sa
import simplejson
import urllib

import pylons
from pylons import c, request, response, config
from pylons.controllers import WSGIController
from pylons.controllers.util import abort
from pylons.decorators import jsonify
from pylons.templating import render_mako as render

from common import decorators as commondecorators

from common.lib import facebook as fblib

from topdish.lib import helpers as h
from topdish.lib.decorators import *
from topdish.lib.exceptions import *

from topdish import model
from topdish.model import cache
from topdish.model import meta
from topdish.model import User
from topdish.model import Listing

render_def = h.render_def

log = logging.getLogger(__name__)

render_def = h.render_def
default_render = render

# create custom render to work with and without ajax
def custom_render(tpl_name, extra_vars={}, **kw):
    def _render(tpl_name, **kwargs):
        if c.is_ajax:
            log.debug('rendering %s/%s partial', c.controller, c.action)
            return render_def(tpl_name, 'partial', **kwargs)

        log.debug('rendering full')
        return default_render(tpl_name, extra_vars=extra_vars, **kwargs)

    if 'cache' in kw:
        cache = kw.pop('cache')
        if 'cache_timeout' in cache:
            cache_timeout = kw.pop('cache_timeout')
        else:
            cache_timeout = 0
    else:
        cache = None

    if cache == 'memcache' and not config['debug']:
        @commondecorators.memcache_memoize(lambda: model.mc, cache_timeout)
        def _cached_render(tpl_name, **kwargs):
            return _render(tpl_name, **kwargs)
        return _cached_render(tpl_name, **kw)
    else:
        if 'cache_key' in kw:
            del kw['cache_key']
        return _render(tpl_name, **kw)

render = custom_render

# ajax responses need to have qualified urls in them
default_url_for = h.url_for
def custom_url_for(*args, **kw):
    if c.is_ajax:
        kw['qualified'] = True
    return default_url_for(*args, **kw)

h.url_for = custom_url_for

class BaseController(WSGIController):

    def __call__(self, environ, start_response):
        """Invoke the Controller"""
        # WSGIController.__call__ dispatches to the Controller method
        # the request is routed to. This routing information is
        # available in environ['pylons.routes_dict']
        try:
            c.controller = environ['pylons.routes_dict'].get('controller')
            c.action = environ['pylons.routes_dict'].get('action')
            ret = WSGIController.__call__(self, environ, start_response)
            return ret
        except:
            meta.rollback_all_sessions()
            log.warn('caught exeption, re-raising', exc_info=True)
            raise
        finally:
            meta.remove_all_sessions()

    def __before__(self):
        """
        From WSGIController documentation:

        This method is called before your action is, and should be used
        for setting up variables/objects, restricting access to other
        actions, or other tasks which should be executed before the
        action is called.
        """
        c.is_ajax = request.environ.get('HTTP_X_REQUESTED_WITH') == 'XMLHttpRequest' or request.params.get('is_ajax')
        log.debug('request begin: %s/%s, %d', c.controller, c.action, int(time.time()))

        self._get_current_site_user()
        c.is_logged_in = bool(h.user())

    def __after__(self):
        """
        From WSGIController documentation:

        This method is called after the action is, unless an unexpected
        exception was raised. Subclasses of
        :class:`~webob.exc.HTTPException` (such as those raised by
        ``redirect_to`` and ``abort``) are expected; e.g. ``__after__``
        will be called on redirects.
        """
        log.debug('request end: %s/%s, %d', c.controller, c.action, int(time.time()))
        if config['debug']:
            response.headers['Cache-Control'] = 'no-cache'

    def _get_current_site_user(self):
        cookies = request.cookies
        cookie = fblib.get_user_from_cookie(cookies, 
                                            h.fb_app_id(), 
                                            h.fb_secret())
        user_id = None
        fb_user_id = None
        fb_access_token = None
        user = None

        if cookie:
            fb_user_id = h.to_i(cookie['uid'])
            fb_access_token = cookie['access_token']
            fb_access_token_expiry = h.to_i(cookie['expires'])
            last_login = int(time.time())
            user = User.find(fb_user_id=fb_user_id).first() if fb_user_id else None
            if not user:
                user = User.factory(fb_user_id, 
                                    fb_access_token=fb_access_token, 
                                    fb_access_token_expiry=fb_access_token_expiry, 
                                    last_login=last_login)
            try:
                user.update_fb_access_token(fb_access_token, fb_access_token_expiry)
            except fblib.GraphAPIError, e:
                log.warning('caught graph api error while updating access token, flushing cookie: %r', e)
                request.cookies.pop('fbs_%s' % h.fb_app_id(), None)

            user_id = user.user_id

        self._setup_helpers(user_id=user_id,
                            fb_user_id=fb_user_id, 
                            fb_access_token=fb_access_token, 
                            user=user)

        return user

    def _setup_helpers(self, 
                       user_id=None, 
                       fb_user_id=None, 
                       fb_access_token=None, 
                       user=None):

        # setup some common helpers
        h.user_id = lambda: user_id
        h.fb_user_id = lambda: fb_user_id
        h.fb_access_token = lambda: fb_access_token
        h.user = lambda: user

        default_api = fblib.GraphAPI(access_token=h.fb_access_token(), 
                                     app_id=h.fb_app_id(),
                                     app_secret=h.fb_secret())
        h.graph_api = lambda: default_api


class RequireUserController(BaseController):
    """
    If no valid user is available from h.user(), show the user a login form
    which will redirect them to whatever url they were trying to goto once they
    login.
    """

    def __before__(self):
        super(RequireUserController, self).__before__()
        if not h.user():
            requested_url = h.url_for(controller=c.controller, 
                                      action=c.action, 
                                      qualified=True)
            args = {'client_id': h.fb_app_id(), 'redirect_uri': requested_url}

            user = None
            if request.params.get("code"):
                log.debug('found code, authorizing the user')

                args["client_secret"] = h.fb_secret()
                args["code"] = request.params["code"]
                
                graph_access_url = "https://graph.facebook.com/oauth/access_token?" + urllib.urlencode(args)
                resp = urllib.urlopen(graph_access_url).read()
                resp = cgi.parse_qs(resp)
                if 'access_token' in resp:
                    expires = int(resp['expires'][0])
                    fb_access_token_expiry = int(time.time()) + expires
                    fb_access_token = resp["access_token"][-1]
                    
                    # get the user's id
                    api = fblib.GraphAPI(fb_access_token)
                    me = api.get_object('me')
                    user = process_fb_user_data(me, fb_access_token, fb_access_token_expiry)

                    # same as parent controller's _get_current_site_user() except we don't have
                    # a cookie to use to get user info
                    self._setup_helpers(user_id=user.user_id,
                                        fb_user_id=fb_user_id, 
                                        fb_access_token=fb_access_token, 
                                        user=user)

            if not user:
                log.debug('no user available, requesting login, url: %r', requested_url)

                args['scope'] = "email"
                #h.redirect_to("https://graph.facebook.com/oauth/authorize?" + urllib.urlencode(args))
                h.redirect_to("https://www.facebook.com/dialog/oauth?" + urllib.urlencode(args))


def process_fb_user_data(fb_data, fb_access_token, fb_access_token_expiry):
    fb_user_id = h.to_i(fb_data['id'])
    email = fb_data['email']
    first_name = fb_data['first_name']
    last_name = fb_data['last_name']

    # resolve the user
    last_login = int(time.time())
    user = User.factory(fb_user_id, 
                        fb_access_token=fb_access_token, 
                        fb_access_token_expiry=fb_access_token_expiry, 
                        email=email,
                        last_login=last_login)

    user.update_fb_access_token(fb_access_token, 
                                fb_access_token_expiry,
                                commit=False)
    user.update_user_fields(field_values=fb_data, commit=True)
    return user
