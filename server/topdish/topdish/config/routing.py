"""Routes configuration

The more specific and detailed routes should be defined first so they
may take precedent over the more generic routes. For more information
refer to the routes manual at http://routes.groovie.org/docs/
"""
from pylons import config
from routes import Mapper

def make_map():
    """Create, configure and return the routes Mapper"""
    map = Mapper(directory=config['pylons.paths']['controllers'],
                 always_scan=config['debug'])
    map.minimization = False

    # The ErrorController route (handles 404/500 error pages); it should
    # likely stay at the top, ensuring it can always be resolved
    map.connect('/error/{action}', controller='error')
    map.connect('/error/{action}/{id}', controller='error')

    # CUSTOM ROUTES HERE
    map_api_routes(map)

    map.connect('/{controller}', action='index')
    map.connect('/{controller}/', action='index')
    map.connect('/{controller}/{action}')
    map.connect('/{controller}/{action}/')

    return map

def map_api_routes(map):
    def api_route(base, **kw):
        map.connect('/api/%s' % base, **kw)
        map.connect('/api/%s/' % base, **kw)

    # credentials
    map.connect('facebookLogin', controller='api/credentials_api', action='facebook')
    map.connect('googleAuth', controller='api/credentials_api', action='google')

    # photos
    map.connect('addPhoto', controller='api/photo_api', action='add')

    # feedback
    map.connect('sendUserFeedback', controller='api/feedback_api', action='add')

    # dishes
    map.connect('addDish', controller='api/dish_api', action='add')
    map.connect('dishDetail', controller='api/dish_api', action='detail')
    map.connect('dishSearch', controller='api/dish_api', action='search')
    map.connect('flagDish', controller='api/dish_api', action='flag')
    map.connect('rateDish', controller='api/dish_api', action='rate')

    # restaurants
    map.connect('addRestaurant', controller='api/restaurant_api', action='add')
    map.connect('restaurantDetail', controller='api/restaurant_api', action='detail')
    map.connect('restaurantSearch', controller='api/restaurant_api', action='search')
    map.connect('flagRestaurant', controller='api/restaurant_api', action='flag')
    map.connect('rateRestaurant', controller='api/restaurant_api', action='rate')
