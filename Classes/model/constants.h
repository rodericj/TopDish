//
//  constants.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "TopDishAppDelegate.h"

#pragma mark -
#pragma mark NSNotificationCenter Strings
#define NSNotificationStringDoneProcessingDishes @"DONEPROCESSINGDISHES"
#define NSNotificationStringDoneProcessingRestaurants @"DONEPROCESSINGRESTAURANTS"

#pragma mark -
#pragma mark NSManagedObjectContext
#define kManagedObjectContect [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]

#define kpermission  [NSArray arrayWithObjects:@"user_about_me", @"email", @"publish_stream", @"friends_about_me", nil]

#pragma mark -
#pragma mark image constants

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"
#define FILTER_IMAGE_NAME @"filter.png"
#define GLOBAL_IMAGE_NAME @"globe-1.png"

#pragma mark -
#pragma mark logging
#ifdef TARGET_IPHONE_SIMULATOR
#define DLog(fmt, ...) NSLog((@"%s [Line %d] [%@]" fmt), __PRETTY_FUNCTION__, __LINE__, [[NSThread currentThread] isMainThread] ? @"Main thread": [[NSThread currentThread] description], ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#pragma mark -
#pragma mark network constants
//#define NETWORKHOST @"http://0305.topdish1.appspot.com"
#define NETWORKHOST @"http://0320.topdish1.appspot.com" 
//#define NETWORKHOST @"http://localhost:8888"
//#define NETWORKHOST @"http://www.topdish.com"
//#define NETWORKHOST @"http://192.168.0.185:8888"   //randy
//#define NETWORKHOST @"http://10.0.1.4:8888"  //rod

#pragma mark -
#pragma mark ivars

#define MAXRESTAURANTNAMELENGTH 26
#define OBJECTDETAILIMAGECELLHEIGHT 88
#define IPHONESCREENWIDTH 320
#define IPHONESCREENHEIGHT 480
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define DISHLISTCELLHEIGHT 93

#define kFBAppId @"142175135835907"

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
//#define RATINGS_SORT @"calculated_rating"
#define RATINGS_SORT @"posReviews"
#define DISTANCE_SORT @"distance"
#define PRICE_SORT @"price"

#define kSortByDistance 1
#define kSortByRating 2
#define kSortByPrice 3

#define SIGNIN_Y_COORD -100

#define kTopDishBackground [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_tile.png"]]
#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]

#define kPriceType	0
#define kMealType	1
#define kAllergenType 4
#define kLifestyleType 3
#define kCuisineType 2

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

#pragma mark tags

#define RESTAURANT_TABLEVIEW_DISH_NAME_TAG 1
#define RESTAURANT_TABLEVIEW_ADDRESS_TAG 2
#define RESTAURANT_TABLEVIEW_PHONE_TAG 3
#define RESTAURANT_TABLEVIEW_DISTANCE_TAG 4
#define RESTAURANT_TABLEVIEW_POSREVIEWS_TAG 5
#define RESTAURANT_TABLEVIEW_NEGREVIEWS_TAG 6
#define RESTAURANT_TABLEVIEW_IMAGE_TAG 7
//#define RESTAURANT_TABLEVIEW_RESTAURENT_SCORE_TAG 6

#define kOneMileInMeters 1609.344


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

