import logging

from topdish.lib.base import *
from topdish.lib import security as securitylib

log = logging.getLogger(__name__)

class BaseApiController(WSGIController):

    def __before__(self):
        self._setup_helpers()

    def _setup_helpers(self):
        h.user_id = lambda: None

        routes_dict = request.environ['pylons.routes_dict']
        h.controller = lambda: routes_dict.get('controller')
        h.action = lambda: routes_dict.get('action')

    def _get_dispatch_action_fn(self):
        action = request.environ['pylons.routes_dict']['action'].replace('-', '_')
        return getattr(self, action, None)

    def _dispatch_call(self):
        try:
            if request.method == 'OPTIONS' or h.request_param('doc'):
                pylons.response.headers['Content-Type'] = 'text/plain'
                url = h.url_for(controller=h.controller(), 
                                action=h.action(), 
                                qualified=True,
                                **request.params) 

                doc = self._get_dispatch_action_fn().__doc__ or 'No Documentation'
                return 'Requested: %s\n%s' % (url, doc)
            else:
                return super(BaseApiController, self)._dispatch_call()

        except Exception, e:
            log.error('API error', exc_info=True)
            meta.rollback_all_sessions()
            raise
        finally:
            meta.remove_all_sessions()
