import logging

from topdish.controllers.api import *

log = logging.getLogger(__name__)

class FeedbackApiController(BaseApiController):

    @request_debug
    def index(self):
        """
        POST:

            Request parameters:

            Returns:

        DELETE:
        """
        return {'POST': self._index_post}.get(request.method, 
                                              lambda x: abort(404))()

    @secure_api
    def _index_post(self):
        pass
