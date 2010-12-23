//
//  constants.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define MAXRESTAURANTNAMELENGTH 26
#define DISHDETAILIMAGECELLHEIGHT 72
#define IPHONESCREENWIDTH 320
#define IPHONESCREENHEIGHT 480
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define DISHLISTCELLHEIGHT 72

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"

#pragma mark network constants
#define NETWORKHOST @"http://topdish1.appspot.com"

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
#define MIN_PRICE_VALUE_LOCATION @"minpricevaluelocation"
#define MAX_PRICE_VALUE_LOCATION @"maxpricevaluelocation"
#define SORT_VALUE_LOCATION @"sortvaluelocation"
#define RATINGS_SORT @"posReviews"
#define DISTANCE_SORT @"distance"

#pragma tags

#define DISHDETAILIMAGETAG 1
#define DISHTABLEVIEW_DISH_NAME_TAG 1
#define DISHTABLEVIEW_RESTAURANT_NAME_TAG 2
#define DISHTABLEVIEW_COST_TAG 3
#define DISHTABLEVIEW_UPVOTES_TAG 4
#define DISHTABLEVIEW_DOWNVOTES_TAG 6
#define DISHTABLEVIEW_IMAGE_TAG 8
#define DISHTABLEVIEW_DIST_TAG 9

#define COMMENTOR_NAME_TAG 1
#define COMMENT_TEXT_TAG 2
#define COMMENT_DIRECTION_IMAGE_TAG 0

#define AirplaneMode YES

#define DishSearchResponseText @"[{\"id\":164001,\"name\":\"aaaa\",\"description\":\"bbb\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164002,\"name\":\"ccccc\",\"description\":\"ddddd\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164003,\"name\":\"eeee\",\"description\":\"fffff\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]"
#define RestaurantResponseText @"{\"dishes\":[{\"id\":164001,\"name\":\"Breakfast Burrito\",\"description\":\"A Large white flour tortilla, filled with meat, beans, cheese, salsa, or a combination of these, and rolled. Served smothered with chile sauce and melted cheese\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]}"
#define RestaurantResponsetext @"[\
{\
\"id\":2312,\
\"name\":\"Blush\",\
\"addressLine1\":\"476 Castro Street\",\
\"addressLine2\":\"\",\
\"city\":\"San Francisco\",\
\"state\":\"CA\",\
\"neighborhood\":\"\",\
\"latitude\":37.761203,\
\"longitude\":-122.4350654,\
\"phone\":\"4155580893\",\
\"numDishes\":3,\
\"photoURL\":\"\",\
\"dishes\":\
[\
{\
\"id\":2313,\
\"name\":\"some dish name\",\
\"description\":\"food on a plate\",\
\"restaurantID\":2312,\
\"latitude\":37.761203,\
\"longitude\":-122.4350654,\
\"restaurantName\":\"Blush\",\
\"posReviews\":1,\
\"negReviews\":0,\
\"photoURL\":\"”\
},\
{\
	\"id\":2316,\
	\"name\":\"Another dish title\",\
	\"description\":\"ss\",\
	\"restaurantID\":2312,\
	\"latitude\":37.761203,\
	\"longitude\":-122.4350654,\
	\"restaurantName\":\"Blush\",\
	\"posReviews\":0,\
	\"negReviews\":1,\
	\"photoURL\":\"”\
	},\
	{\
	\"id\":2329,\
	\"name\":\"a very long name for a drink\",\
		\"description\":\"s\",\
		\"restaurantID\":2312,\
		\"latitude\":37.761203,\
		\"longitude\":-122.4350654,\
		\"restaurantName\":\"Blush\",\
		\"posReviews\":1,\
		\"negReviews\":0,\
		\"photoURL\":\"”\
		}\
]\
},\
{\
	\"id\":2319,\
	\"name\":\"PizzaHacker\",\
	\"addressLine1\":\"Mission District\",\
	\"addressLine2\":\"\",\
	\"city\":\"San Francisco\",\
	\"state\":\"CA\",\
	\"neighborhood\":\"\",\
	\"latitude\":37.76,\
	\"longitude\":-122.42,\
	\"phone\":\"4158745585\",\
	\"numDishes\":1,\
	\"photoURL\":\"\",\
	\"dishes\":\
	[\
	{\\
		\"id\":2320,\
		\"name\":\"Hax0r Pizza\",\
		\"description\":\"some fine ass pizza\",\
		\"restaurantID\":2319,\
		\"latitude\":37.76,\
		\"longitude\":-122.42,\
		\"restaurantName\":\"PizzaHacker\",\
		\"posReviews\":1,\
		\"negReviews\":0,\
		\"photoURL\":\"\”\
		}\
		]\
		}\
		]"
#define cool 1