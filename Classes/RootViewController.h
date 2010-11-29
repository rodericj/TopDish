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
#import "DishTableViewer.h"

@interface RootViewController : DishTableViewer <MyCLControllerDelegate, NSFetchedResultsControllerDelegate> {
	MyCLController *locationController;
	NSString *currentLat;
	NSString *currentLon;
	
	UIImageView *bgImage;
    UITableView *theTableView;
    UISearchBar *theSearchBar;

	UISegmentedControl *dishRestoSelector;
}

- (NSNumber *) calculateDishDistance:(id *)dish;
- (void) updateSettings:(NSDictionary *)settings;
- (void)getNearbyItems:(CLLocation *)location;
- (NSArray *) getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString*) key;
- (NSArray *)loadDummyRestaurantData;

@property (nonatomic, retain) NSString *currentLat;
@property (nonatomic, retain) NSString *currentLon;
@property (nonatomic, retain) UISegmentedControl *dishRestoSelector;
@property (nonatomic, retain) IBOutlet UIImageView *bgImage;



@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;


@end
