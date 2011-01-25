//
//  constants.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define NSZombiesEnabled YES

#define MAXRESTAURANTNAMELENGTH 26
#define DISHDETAILIMAGECELLHEIGHT 88
#define IPHONESCREENWIDTH 320
#define IPHONESCREENHEIGHT 480
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define DISHLISTCELLHEIGHT 93

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"

#pragma mark network constants
//#define NETWORKHOST @"http://topdish1.appspot.com"
//#define NETWORKHOST @"http://localhost:8888"
#define NETWORKHOST @"http://testing-randy.topdish1.appspot.com"
//#define NETWORKHOST @"http://10.0.1.11:8888"

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
#define MIN_PRICE_VALUE_LOCATION @"minpricevaluelocation"
#define MAX_PRICE_VALUE_LOCATION @"maxpricevaluelocation"
#define SORT_VALUE_LOCATION @"sortvaluelocation"
#define RATINGS_SORT @"posReviews"
#define DISTANCE_SORT @"distance"

#pragma tags

#define RESTAURANT_TABLEVIEW_DISH_NAME_TAG 1

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

#define kTopDishBackground [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_tile.png"]]
#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]

#define kPriceType	1
#define kMealType	2

#define kAccountsTab 1

#define keyforauthorizing @"apiKey"

//#define AirplaneMode YES

#define DishSearchResponseText @"[{\"id\":164001,\"name\":\"aaaa\",\"description\":\"bbb\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164002,\"name\":\"ccccc\",\"description\":\"ddddd\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164003,\"name\":\"eeee\",\"description\":\"fffff\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]"
//#define DishSearchResponseText @"[{\"id\":164001,\"name\":\"aaaa\",\"description\":\"bbb\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]"
#define RestaurantResponseText @"{\"dishes\":[{\"id\":164001,\"name\":\"Breakfast Burrito\",\"description\":\"A Large white flour tortilla, filled with meat, beans, cheese, salsa, or a combination of these, and rolled. Served smothered with chile sauce and melted cheese\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]}"
