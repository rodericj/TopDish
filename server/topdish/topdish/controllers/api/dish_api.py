import logging

from topdish.controllers.api import *

log = logging.getLogger(__name__)

class DishApiController(BaseApiController):

    def __before__(self):
        h.dish_id = lambda: h.to_i(h.request_param('dishId'))

    @secure_api
    def add(self):
        """
        POST:

            Request parameters:

            Returns:
        """
        pass

    @api
    def detail(self):
        """
        GET:

            Request parameters:

            Returns:
        """
        pass

    @api
    def search(self):
        """
        GET:

            Request parameters:

            Returns:
        """
        pass

    @secure_api
    def flag(self):
        """
        POST:

            Request parameters:

            Returns:
        """
        pass

    @secure_api
    def rate(self):
        """
        POST:

            Request parameters:

            Returns:
        """
        pass
