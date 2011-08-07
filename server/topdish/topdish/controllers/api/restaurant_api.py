import logging

from topdish.controllers.api import *

log = logging.getLogger(__name__)

class RestaurantApiController(BaseApiController):

    def __before__(self):
        h.restaurant_id = lambda: h.to_i(h.request_param('restaurantId'))

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
