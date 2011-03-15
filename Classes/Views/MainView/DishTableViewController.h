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
#import "ObjectWithImage.h"

@interface DishTableViewController :UITableViewController <MyCLControllerDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
	MyCLController *locationController;
	NSString *mCurrentLat;
	NSString *mCurrentLon;
	NSString *mCurrentSearchTerm;
	int mCurrentSearchDistance;
	
	IBOutlet UIImageView *dummyImage;
	
	
	IBOutlet UIView *mSearchHeader;
	IBOutlet UISearchBar *mTheSearchBar;

	UIImageView *mBgImage;
		
	UILabel *mRatingTextLabel;
	UILabel *mPriceTextLabel;
	UILabel *mDistanceTextLabel;
		
	NSManagedObjectContext *mManagedObjectContext;
    NSFetchedResultsController *mFetchedResultsController;

	NSURLConnection *mConn;
	NSMutableData *mResponseData;

	UITableViewCell				*mAddItemCell;
	UITableViewCell				*mTvCell;

}

- (void) updateFetch;
- (void)getNearbyItems:(CLLocation *)location;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
-(IBAction) sortByDistance;
-(IBAction) sortByRating;
-(IBAction) sortByPrice;

@property (nonatomic, retain) IBOutlet UITableViewCell *addItemCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) NSString *currentSearchTerm;
@property (nonatomic, assign) int currentSearchDistance;

@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *searchHeader;

@property (nonatomic, retain) IBOutlet UILabel *ratingTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceTextLabel;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSURLConnection *conn;
@property (nonatomic, retain) NSMutableData *responseData;

-(void) networkQuery:(NSString *)query;
-(void)processIncomingNetworkText:(NSString *)responseText;
-(void) pushDishViewController:(ObjectWithImage *) selectedObject;
-(UITableViewCell *)tableView:(UITableView *)tableView dishCellAtIndexPath:(NSIndexPath *)indexPath;

@end