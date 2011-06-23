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
#import "IncomingProcessor.h"
#import "LoginModalView.h"
#import "DishTableViewCell.h"
#import "DistanceUpdator.h"
#import "SettingsView1.h"

@interface DishTableViewController :UITableViewController 
<MyCLControllerDelegate, 
NSFetchedResultsControllerDelegate, 
UISearchBarDelegate, 
IncomingProcessorDelegate,
LoginModalViewDelegate,
DistanceUpdatorDelegate,
SettingsViewDelegate> {
	MyCLController *locationController;
	NSString *mCurrentLat;
	NSString *mCurrentLon;
	NSString *mCurrentSearchTerm;
	int mCurrentSearchDistance;
	
	IBOutlet UIView *mSearchHeader;
	IBOutlet UISearchBar *mTheSearchBar;

	UIImageView *mBgImage;
		
	UILabel *mRatingTextLabel;
	UILabel *mPriceTextLabel;
	UILabel *mDistanceTextLabel;
		
    NSFetchedResultsController *mFetchedResultsController;

	NSURLConnection *mConn;

	UITableViewCell				*mAddItemCell;
	DishTableViewCell				*mTvCell;

	NSMutableDictionary *mConnectionLookup;
	
	UIImageView			*mCurrentSortIndicator;
	
	dispatch_queue_t	mImageDownloadQueue;
	
	NSTimer				*mStallSearchTextTimer;
}

- (void) updateFetch;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
-(IBAction) sortByDistance;
-(IBAction) sortByRating;
-(IBAction) sortByPrice;

@property (nonatomic, retain) IBOutlet UITableViewCell *addItemCell;
@property (nonatomic, assign) IBOutlet DishTableViewCell *tvCell;

@property (nonatomic, retain) NSString *currentSearchTerm;
@property (nonatomic, assign) int currentSearchDistance;

@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *searchHeader;

@property (nonatomic, retain) IBOutlet UILabel *ratingTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceTextLabel;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet	UIImageView		*currentSortIndicator;

@property (nonatomic, retain)			NSTimer			*stallSearchTextTimer;


-(void) networkQuery:(NSString *)query;
-(void) pushDishViewController:(ObjectWithImage *) selectedObject;

@end
