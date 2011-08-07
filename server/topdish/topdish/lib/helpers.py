import hashlib
import itertools
import logging
import simplejson

from pylons import config
from pylons.controllers.util import url_for
from pylons.controllers.util import redirect_to

import webhelpers

from common import *
from common.lib.helpers import *

from topdish import model

log = logging.getLogger(__name__)

def fb_app_id():
    return config['facebook.app_id']

def fb_secret():
    return config['facebook.secret_key']

def verify_session_sig(sig, *params):
    if not sig or not params:
        return False

    if 'sig' in params:
        del params['sig']

    params = params.sorted()
    return site_hash(params) == sig

def site_hash(*args):
    args_iter = itertools.chain(args, (site_secret(),))
    return hashlib.sha256(','.join(itertools.imap(str, args_iter))).hexdigest()

def site_sig(**params):
    return site_hash(params.values())

def site_secret():
    return config['site.secret']

def controller():
    from pylons import c
    return c.routes_dict['controller']

def action():
    from pylons import c
    return c.routes_dict['action']

def get_flash_messages(type='info'):
    from pylons import session
    queue = []
    try:
        queue = session.get('flash_%s' % type, '[]')
    except Exception, e:
        log.warning('could not decode flash messages')
    finally:
        return queue

def add_flash_message(msg, type='info'):
    from pylons import session
    msgs = get_flash_messages(type)
    msgs.append(msg)
    session['flash_%s' % type] = msgs
    session.save()

def ellipses(text, max_len=10):
    return webhelpers.text.truncate(text, length=max_len)

def get_current_url():
    from pylons import request
    url = "%s?%s" % (request.path_info.lstrip('/'), request.environ['QUERY_STRING'])
    return url

JSON_REQUEST_ENVIRON_KEY = '__parsed_json_body'
def request_param(name, default=None):
    from pylons import request
    val = request.params.get(name, default)

    if request.content_type == 'application/json':
        if JSON_REQUEST_ENVIRON_KEY not in request.environ and request.body:
            try:
                parsed = simplejson.loads(request.body)
            except Exception, e:
                log.error('could not parse json body', exc_info=True)
                parsed = {}
            
            request.environ[JSON_REQUEST_ENVIRON_KEY] = parsed

        val = request.environ[JSON_REQUEST_ENVIRON_KEY].get(name) or val

    return val
