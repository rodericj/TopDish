import logging

from topdish.controllers.api import *

log = logging.getLogger(__name__)

class PhotoApiController(BaseApiController):

    def __before__(self):
        h.dish_id = lambda: h.to_i(h.request_param('dishId'))
        h.restaurant_id = lambda: h.to_i(h.request_param('restaurantId'))

    @request_debug
    def index(self):
        """
        GET/POST:

            Request parameters:

            Returns:
        POST:

            Request parameters:

            Returns:

        DELETE:
        """
        return {'GET': self._index_get,
                'POST': self._index_post,
                'DELETE': self._index_delete}.get(request.method, lambda x: abort(404))()

    @api
    def _index_get(self):
        pass

    @secure_api
    def _index_delete(self):
        pass

    @secure_api
    def _index_post(self):
        pass
