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

#define NSNotificationStringDoneLogin @"DONELOGIN"
#define NSNotificationStringDoneFacebookLogin @"DONEFACEBOOKLOGIN"
#define NSNotificationStringFailedLogin @"FAILEDLOGIN"

#pragma mark -
#pragma mark NSManagedObjectContext
#define kManagedObjectContext [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]

#define kpermission  [NSArray arrayWithObjects:@"user_about_me", @"offline_access", @"email", @"publish_stream", @"friends_about_me", nil]

#pragma mark -
#pragma mark image constants

#define POSITIVE_REVIEW_IMAGE_NAME @"greenup.gif"
#define NEGATIVE_REVIEW_IMAGE_NAME @"reddown.gif"
#define FILTER_IMAGE_NAME @"filter.png"
#define FILTER_ON_IMAGE_NAME @"filter_on.png"
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
//#define NETWORKHOST @"http://0528.topdish1.appspot.com"
#define NETWORKHOST @"http://topdish1.appspot.com" 
//#define NETWORKHOST @"http://whee.topdish1.appspot.com" 
//#define NETWORKHOST @"http://192.168.0.193:8888"
//#define NETWORKHOST @"http://localhost:8888"
//#define NETWORKHOST @"http://www.topdish.com"
//#define NETWORKHOST @"http://192.168.0.185:8888"   //randy
//#define NETWORKHOST @"http://10.0.1.4:8888"  //rod

#pragma mark -
#pragma mark ivars

#define kOneMileInMeters 1609.344
#define kMinimumDishesToShow 25

#define MAXRESTAURANTNAMELENGTH 26
#define OBJECTDETAILIMAGECELLHEIGHT 88
#define IPHONESCREENWIDTH 320
#define IPHONESCREENHEIGHT 480
#define NUMBEROFROWSINDISHDETAILVIEW 4
#define DISHDETAILDEFAULCELLHEIGHT 40
#define DISHLISTCELLHEIGHT 93

#define DEFAULTIMAGEDIMENSION  384

#define kFBAppId @"142175135835907"

#define MIXPANEL_TOKEN @"17b52038f9d40e6a5f7b6847e0c55ce8"

#define kSearchTimerDelay 2

#define DISH_DETAIL_CELL_IDENTIFIER @"dishdetailimagecell"
//#define RATINGS_SORT @"calculated_rating"
#define RATINGS_SORT @"posReviews"
#define DISTANCE_SORT @"distance"
#define PRICE_SORT @"price"

#define kSortByDistance 1
#define kSortByRating 2
#define kSortByPrice 3

#define SIGNIN_Y_COORD -100

#define kTopDishBackground [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background_tile.png"]] autorelease]
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
#define TD_FB_ACCESS_TOKEN_KEY @"TD_FB_ACCESS_TOKEN_KEY"
#define TD_FB_EXPIRATION_DATE_KEY @"TD_FB_EXPIRATION_DATE_KEY"
#define FB_SWITCH_SETTING @"FB_SWITCH_SETTING"

#pragma mark tags

#define COMMENTOR_NAME_TAG 1
#define COMMENT_TEXT_TAG 2
#define COMMENT_DIRECTION_IMAGE_TAG 0

#pragma mark - Logging tags
#pragma mark LoginModalView
#define kEventNotNowButtonClicked               @"Not Now Clicked"
#define kEventfbButtonClicked                   @"FB Button Clicked"
#define kEventGoogleButtonClicked               @"Google Button Clicked"
#define kEventTermsAndConditionsButtonClicked   @"Terms and Conditions Button Clicked"
#define kEventLoginModalViewDidAppear           @"Login Did Appear"

#pragma mark AccountView Logging
#define kEventAViewDidAppear                    @"Account Did Appear"

#pragma mark AddADishView Logging
#define kEventAADViewDidAppear                  @"Add A Dish Did Appear"
#define kEventAADSelectTag                      @"Picked A Tag"
#define kEventAADStartEditingTextView           @"Started Editing Text"
#define kEventAADTapSubmitButton                @"Tap Submit Button"

#pragma mark CommentDetailView
#define kEventCDViewDidAppear                   @"Comment Detail View Did Appear"

#pragma mark DishDetailView
#define kEventDDViewDidAppear                   @"Dish Detail Did Appear"
#define kEventDDTapPictureButton                @"Tap Take Picture"
#define kEventDDTapRateDish                     @"Tap Rate Dish"
#define kEventDDTapMoreDishes                   @"Tap More Dishes"
#define kEventDDTapRestaurantText               @"Tap Restaurant Text"
#define kEventDDTapFlagRestaurant               @"Tap Flag Dish"
#define kEventDDDoneRatingDish                  @"Done Rating Dish"
#define kEventDDTapPhoto                        @"Tap Dish Photo"
#define kEventDDTapEmptyPhoto                   @"Tap Empty Photo"

#pragma mark DishTableView
#define kEventDTViewDidAppear                   @"Dish Table Did Appear"
#define kEventDTSortByRating                    @"Sort Rating"
#define kEventDTSortByDistance                  @"Sort Distance"
#define kEventDTSortByPrice                     @"Sort Price"
#define kEventDTSearch                          @"Dish Search"

#pragma mark RestaurantTableView
#define kEventRTViewWillAppear                  @"Restaurant Table Will Appear"
#define kEventRTSearch                          @"Restaurant Search"

#pragma mark RateADishView
#define kEventRADViewDidAppear                  @"Rate Dish Did Appear"
#define kEventRDVote                            @"Vote"
#define kEventRDSubmitRating                    @"Submit Rating"
#define kEventRDFBPost                          @"FB Stream Post"
#define kEventRDChangeText                      @"Changed Text"

#pragma mark RestaurantDetailView
#define kEventRDViewDidAppear                   @"Restaurant Detail Did Appear"
#define kEventRDTapPhoto                        @"Tap Restaurant Photo"
#define kEventRDDoneAddingDish                  @"Done Adding Dish"
#define kEventRDFlagRestaurant                  @"Flag Restaurant"
#define kEventRDAddDishTapped                   @"Add Dish Tapped"
#define kEventRDCallRestaurant                  @"Call Restaurant"
#define kEventRDTakePicture                     @"Take Photo"
#define kEventRDTapEmptyPhoto                   @"Tap Empty Photo"

#pragma mark NearbyMapView
#define kEventNMViewDidAppear                   @"Nearby Map View Did Appear"
#define kEventNMShowDetails                     @"Show Details from Map"
#define kEventNMMoveMap                         @"Move Map"

#pragma mark Settings/Filter View
#define kEventSViewDidAppear                    @"Settings View Did Appear"
#define kEventSUserPickedSomething              @"Picked a Filter"
