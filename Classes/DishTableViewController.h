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
	NSString *currentLat;
	NSString *currentLon;
	NSString *currentSearchTerm;
	
	NSMutableDictionary *settingsDict;
	
	IBOutlet UIView *searchHeader;
	IBOutlet UISearchBar *theSearchBar;

	UIImageView *bgImage;

	UISegmentedControl *dishRestoSelector;
	
	RestaurantListTableViewDelegate *mrltv;
	
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
@property (nonatomic, retain) UISegmentedControl *dishRestoSelector;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;

@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic, retain) IBOutlet UIView *searchHeader;


@end
