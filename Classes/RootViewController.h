//
//  RootViewController.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MyCLController.h"

@interface RootViewController : UITableViewController <MyCLControllerDelegate, NSFetchedResultsControllerDelegate> {
	MyCLController *locationController;
	NSString *currentLat;
	NSString *currentLon;
	
	UIImageView *bgImage;
    UITableView *theTableView;
    UISearchBar *theSearchBar;

	UISegmentedControl *dishRestoSelector;
	
	UITableViewCell *tvCell;
	NSMutableData *_responseText;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

- (NSNumber *) calculateDishDistance:(id *)dish;
- (void) updateSettings:(NSDictionary *)settings;
- (void)getNearbyItems:(CLLocation *)location;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
- (NSArray *)loadDummyRestaurantData;
-(void) processIncomingNetworkText:(NSString *)responseText;

@property (nonatomic, retain) NSString *currentLat;
@property (nonatomic, retain) NSString *currentLon;
@property (nonatomic, retain) UISegmentedControl *dishRestoSelector;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSMutableData *_responseText;


@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;


@end
