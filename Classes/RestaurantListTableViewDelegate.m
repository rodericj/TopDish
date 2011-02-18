//
//  RestaurantListTableView.m
//  TopDish
//
//  Created by roderic campbell on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RestaurantListTableViewDelegate.h"
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"
#import "constants.h"

@implementation RestaurantListTableViewDelegate

@synthesize tvCell;
@synthesize fetchedResultsController=mFetchedResultsController;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize topNavigationController = mNavigationController;
#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	NSLog(@"there are this many rows in the restaurant view %d", [sectionInfo numberOfObjects]);
	return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"get a cell from the resto list view %@", indexPath);
    static NSString *CellIdentifier = @"RestaurantCell";
    
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	NSLog(@"this restaurant is %@, %d, %@", [thisRestaurant objName], [thisRestaurant restaurant_id], thisRestaurant);

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RestaurantTableViewCell" owner:self options:nil];
		cell = tvCell;
	}

	UILabel *restaurantName;
	restaurantName = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_DISH_NAME_TAG];
	restaurantName.text = thisRestaurant.objName;
	
	NSLog(@"address is %@, phone is %@", thisRestaurant.addressLine1, thisRestaurant.phone);
	UILabel *address;
	address = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_ADDRESS_TAG];
	address.text = thisRestaurant.addressLine1;
	[thisRestaurant addressLine1];
	
	UILabel *phone;
	phone = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_PHONE_TAG];
	phone.text = thisRestaurant.phone;
	
    // Configure the cell...
    return cell;
}

#pragma mark -
#pragma mark Controller
- (NSFetchedResultsController *)fetchedResultsController {
    if (mFetchedResultsController != nil) {
        return mFetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
	
    NSEntityDescription *entity = 
	[NSEntityDescription entityForName:@"Dish"
				inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
	
	// taken out so we can show the restaurant table results
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:self.managedObjectContext 
										  sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![mFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         //TODO remove auto generated abort
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return mFetchedResultsController;
}   


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	self.topNavigationController = nil;
	//self.tvCell = nil;
	self.managedObjectContext = nil;
	self.fetchedResultsController = nil;
}


@end

