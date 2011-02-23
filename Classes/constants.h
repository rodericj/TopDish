//
//  constants.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#define NSZombiesEnabled YES

#define MAXRESTAURANTNAMELENGTH 26
#define DISHDETAILIMAGECELLHEIGHT 88
#define IPHONESCREENWIDTH 320
#define IPHONESCREENHEIGHT 480
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define DISHLISTCELLHEIGHT 93

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"
#define FILTER_IMAGE_NAME @"filter.png"
#define GLOBAL_IMAGE_NAME @"globe-1.png"

#pragma mark network constants
//#define NETWORKHOST @"http://topdish1.appspot.com"
//#define NETWORKHOST @"http://localhost:8888"
#define NETWORKHOST @"http://randy-0203.latest.topdish1.appspot.com"
//#define NETWORKHOST @"http://10.0.1.11:8888"   //randy
//#define NETWORKHOST @"http://10.0.1.4:8888"  //rod


#define kFBAppId @"142175135835907"

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
#define RATINGS_SORT @"calculated_rating"
#define DISTANCE_SORT @"distance"
#define PRICE_SORT @"price"

#define kSortByDistance 0
#define kSortByRating 1
#define kSortByPrice 2

#pragma tags

#define RESTAURANT_TABLEVIEW_DISH_NAME_TAG 1
#define RESTAURANT_TABLEVIEW_ADDRESS_TAG 2
#define RESTAURANT_TABLEVIEW_PHONE_TAG 3
#define RESTAURANT_TABLEVIEW_DISTANCE_TAG 4
#define RESTAURANT_TABLEVIEW_POSREVIEWS_TAG 5
#define RESTAURANT_TABLEVIEW_NEGREVIEWS_TAG 6
//#define RESTAURANT_TABLEVIEW_RESTAURENT_SCORE_TAG 6


#define DISHDETAILIMAGETAG 1
#define DISHTABLEVIEW_DISH_NAME_TAG 1
#define DISHTABLEVIEW_RESTAURANT_NAME_TAG 2
#define DISHTABLEVIEW_COST_TAG 3

#define DISHTABLEVIEW_UPVOTES_TAG 4
#define DISHTABLEVIEW_MEALTYPE_TAG 5
#define DISHTABLEVIEW_DOWNVOTES_TAG 6
#define PERCENTAGE_TAG 7
#define DISHTABLEVIEW_IMAGE_TAG 8
#define DISHTABLEVIEW_DIST_TAG 9

#define COMMENTOR_NAME_TAG 1
#define COMMENT_TEXT_TAG 2
#define COMMENT_DIRECTION_IMAGE_TAG 0

#define SIGNIN_Y_COORD -100

#define kTopDishBackground [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_tile.png"]]
#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]

#define kPriceType	0
#define kMealType	1
#define kAllergenType 2
#define kLifestyleType 3
#define kCuisineType 4

#define kFlagINACCURATE = 0;
#define kFlagSPAM = 1;
#define kFlagINAPPROPRIATE = 2;

#define kAccountsTab 1

#define kMealTypeString @"Meal Type"
#define kPriceTypeString @"Price"
#define kAllergenTypeString @"Allergen"
#define kLifestyleTypeString @"Lifestyle"
#define kCuisineTypeString @"Cuisine"

#define keyforauthorizing @"apiKey"

//#define AirplaneMode YES
#define mobileInitResponseText @"[{\"id\":217002,\"name\":\"Breakfast\",\"type\":\"Meal Type\",\"order\":0},{\"id\":987004,\"name\":\"Side\",\"type\":\"Meal Type\",\"order\":0},{\"id\":231002,\"name\":\"Sandwich\",\"type\":\"Meal Type\",\"order\":1},{\"id\":239001,\"name\":\"Soup\",\"type\":\"Meal Type\",\"order\":2},{\"id\":219002,\"name\":\"Salad\",\"type\":\"Meal Type\",\"order\":3},{\"id\":195002,\"name\":\"Starter\",\"type\":\"Meal Type\",\"order\":4},{\"id\":232003,\"name\":\"Entree\",\"type\":\"Meal Type\",\"order\":5},{\"id\":240001,\"name\":\"Dessert\",\"type\":\"Meal Type\",\"order\":6},{\"id\":219003,\"name\":\"Drink\",\"type\":\"Meal Type\",\"order\":7},{\"id\":55001,\"name\":\"Less than $5\",\"type\":\"Price\",\"order\":0},{\"id\":56001,\"name\":\"$5-$10\",\"type\":\"Price\",\"order\":1},{\"id\":56002,\"name\":\"$11-$15\",\"type\":\"Price\",\"order\":2},{\"id\":57001,\"name\":\"$16-$20\",\"type\":\"Price\",\"order\":3},{\"id\":238001,\"name\":\"$20+\",\"type\":\"Price\",\"order\":4}]"
//#define mobileInitResponseText @"[{\"id\":217002,\"name\":\"Breakfast\",\"type\":\"Meal Type\",\"order\":0},\"{\"id\":987004,\"name\":\"Side\",\"type\":\"Meal Type\",\"order\":0},{\"id\":231002,\"name\":\"Sandwich\",\"type\":\"Meal Type\",\"order\":1},{\"id\":239001,\"name\":\"Soup\",\"type\":\"Meal Type\",\"order\":2},{\"id\":219002,\"name\":\"Salad\",\"type\":\"Meal Type\",\"order\":3},{\"id\":195002,\"name\":\"Starter\",\"type\":\"Meal Type\",\"order\":4},{\"id\":232003,\"name\":\"Entree\",\"type\":\"Meal Type\",\"order\":5},{\"id\":240001,\"name\":\"Dessert\",\"type\":\"Meal Type\",\"order\":6},{\"id\":219003,\"name\":\"Drink\",\"type\":\"Meal Type\",\"order\":7},{\"id\":55001,\"name\":\"Less than $5\",\"type\":\"Price\",\"order\":0},{\"id\":56001,\"name\":\"$5-$10\",\"type\":\"Price\",\"order\":1},{\"id\":56002,\"name\":\"$11-$15\",\"type\":\"Price\",\"order\":2},{\"id\":57001,\"name\":\"$16-$20\",\"type\":\"Price\",\"order\":3},{\"id\":238001,\"name\":\"$20+\",\"type\":\"Price\",\"order\":4}]"	
#define DishSearchResponseText @"[{\"id\":164001,\"name\":\"aaaa\",\"description\":\"bbb\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164002,\"name\":\"ccccc\",\"description\":\"ddddd\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"},{\"id\":164003,\"name\":\"eeee\",\"description\":\"fffff\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]"
//#define DishSearchResponseText @"[{\"id\":164001,\"name\":\"aaaa\",\"description\":\"bbb\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]"
#define RestaurantResponseText @"{\"dishes\":[{\"id\":164001,\"name\":\"Breakfast Burrito\",\"description\":\"A Large white flour tortilla, filled with meat, beans, cheese, salsa, or a combination of these, and rolled. Served smothered with chile sauce and melted cheese\",\"restaurantID\":163001,\"latitude\":37.793075,\"longitude\":-122.421094,\"restaurantName\":\"La Parrilla Grill - Polk\",\"posReviews\":1,\"negReviews\":0,\"photoURL\":\"/getPhoto?id=167001\"}]}"
