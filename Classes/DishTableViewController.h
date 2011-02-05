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
#import "BaseDishTableViewer.h"
#import "RestaurantListTableViewDelegate.h"

@interface DishTableViewController : BaseDishTableViewer <MyCLControllerDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
	MyCLController *locationController;
	NSString *mCurrentLat;
	NSString *mCurrentLon;
	NSString *mCurrentSearchTerm;
	int mCurrentSearchDistance;
	
	NSMutableDictionary *mSettingsDict;
	
	IBOutlet UIView *mSearchHeader;
	IBOutlet UISearchBar *mTheSearchBar;

	UIImageView *mBgImage;

	UISegmentedControl *mDishRestoSelector;
	
	RestaurantListTableViewDelegate *mrltv;
	
	UILabel *mRatingTextLabel;
	UILabel *mPriceTextLabel;
	UILabel *mDistanceTextLabel;
}

- (NSNumber *) calculateDishDistance:(id *)dish;
- (void) updateFetch;
- (void)getNearbyItems:(CLLocation *)location;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
-(IBAction) sortByDistance;
-(IBAction) sortByRating;
-(IBAction) sortByPrice;

//@property (nonatomic, retain) NSString *entityTypeString;
@property (nonatomic, retain) RestaurantListTableViewDelegate *rltv;

@property (nonatomic, retain) NSMutableDictionary *settingsDict;
@property (nonatomic, retain) NSString *currentSearchTerm;
@property (nonatomic, retain) NSString *currentLat;
@property (nonatomic, retain) NSString *currentLon;
@property (nonatomic, assign) int currentSearchDistance;

@property (nonatomic, retain) UISegmentedControl *dishRestoSelector;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *searchHeader;

@property (nonatomic, retain) IBOutlet UILabel *ratingTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceTextLabel;


@end
