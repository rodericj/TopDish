//
//  DishTableViewController.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MyCLController.h"
//#import "BaseDishTableViewer.h"
#import "ObjectWithImage.h"
#import "RestaurantListTableViewDelegate.h"
#import "RestaurantList.h"

@interface DishTableViewController :UITableViewController <MyCLControllerDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
	MyCLController *locationController;
	NSString *mCurrentLat;
	NSString *mCurrentLon;
	NSString *mCurrentSearchTerm;
	int mCurrentSearchDistance;
	
	IBOutlet UIImageView *dummyImage;
	
	NSMutableDictionary *mSettingsDict;
	
	IBOutlet UIView *mSearchHeader;
	IBOutlet UISearchBar *mTheSearchBar;

	UIImageView *mBgImage;
	
	RestaurantListTableViewDelegate *mrltv;
	
	UILabel *mRatingTextLabel;
	UILabel *mPriceTextLabel;
	UILabel *mDistanceTextLabel;
	
	RestaurantList *mRestaurantList;
	
	NSManagedObjectContext *mManagedObjectContext;
    NSFetchedResultsController *mFetchedResultsController;

	NSURLConnection *mConn;
	NSMutableData *mResponseData;

	UITableViewCell				*mAddItemCell;
	UITableViewCell				*mTvCell;

}

- (NSNumber *) calculateDishDistance:(id *)dish;
- (void) updateFetch;
- (void)getNearbyItems:(CLLocation *)location;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
-(IBAction) sortByDistance;
-(IBAction) sortByRating;
-(IBAction) sortByPrice;

@property (nonatomic, retain) RestaurantListTableViewDelegate *rltv;
@property (nonatomic, retain) IBOutlet UITableViewCell *addItemCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) NSMutableDictionary *settingsDict;
@property (nonatomic, retain) NSString *currentSearchTerm;
@property (nonatomic, retain) NSString *currentLat;
@property (nonatomic, retain) NSString *currentLon;
@property (nonatomic, assign) int currentSearchDistance;

@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *searchHeader;

@property (nonatomic, retain) IBOutlet UILabel *ratingTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceTextLabel;

@property (nonatomic, retain) IBOutlet RestaurantList *restaurantList;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *responseData;

-(void) networkQuery:(NSString *)query;
-(void)processIncomingNetworkText:(NSString *)responseText;
-(void) pushDishViewController:(ObjectWithImage *) selectedObject;
-(UITableViewCell *)tableView:(UITableView *)tableView dishCellAtIndexPath:(NSIndexPath *)indexPath;

@end
