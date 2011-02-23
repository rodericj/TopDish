//
//  RestaurantList.m
//  TopDish
//
//  Created by roderic campbell on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestaurantList.h"
#import "constants.h"
#import "Restaurant.h"
#import "RestaurantDetailViewController.h"

@implementation RestaurantList

@synthesize fetchedResultsController = mFetchedResultsController;
@synthesize managedObjectContext = mManagedObjectContext;
@synthesize tvCell = mTvCell;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        self.title = @"Restaurants";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationController.navigationBar.tintColor = kTopDishBlue;

}
-(void)viewWillAppear:(BOOL)animated {
	UISegmentedControl *s = (UISegmentedControl *) self.navigationItem.titleView;
	[s setSelectedSegmentIndex:1];
}

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;
	//return 45;
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"get a cell from the resto list view %@", indexPath);
    static NSString *CellIdentifier = @"RestaurantCell";
    
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	NSLog(@"this restaurant is %@", thisRestaurant);
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"RestaurantTableViewCell" owner:self options:nil];
		cell = self.tvCell;
	}
	
	UILabel *restaurantName;
	restaurantName = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_DISH_NAME_TAG];
	restaurantName.text = thisRestaurant.objName;
	
	UILabel *addressLabel;
	addressLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_ADDRESS_TAG];
	addressLabel.text = thisRestaurant.addressLine1;
	
	UILabel *phoneNumberLabel;
	phoneNumberLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_PHONE_TAG];
	phoneNumberLabel.text = thisRestaurant.phone;
	
	
//#define RESTAURANT_TABLEVIEW_DISTANCE_TAG 4
//#define RESTAURANT_TABLEVIEW_POSREVIEWS_TAG 5
//#define RESTAURANT_TABLEVIEW_NEGREVIEWS_TAG 6
//#define RESTAURANT_TABLEVIEW_RESTAURENT_SCORE_TAG 6
	UILabel *distanceLabel;
	distanceLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_DISTANCE_TAG];
	distanceLabel.text = @"TODO";
	
	UILabel *positiveReviewsLabel;
	positiveReviewsLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_POSREVIEWS_TAG];
	positiveReviewsLabel.text = @"0";
	
	UILabel *negativeReviewsLabel;
	negativeReviewsLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_NEGREVIEWS_TAG];
	negativeReviewsLabel.text = @"0";	
	
	//UILabel *restaurantScoreLabel;
	//restaurantScoreLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_RESTAURENT_SCORE_TAG];
	//restaurantScoreLabel.text = @"TODO";
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	

	RestaurantDetailViewController *viewController = 
	[[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" 
													 bundle:nil];
	[viewController setRestaurant:thisRestaurant];
	[viewController setManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	
}

#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
			//I'm taking this out. It was an empty function call anyway
           // [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Fetched results controller

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Restaurant" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	
	// [self decorateFetchRequest:fetchRequest];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
	
	// taken out so we can show the restaurant table results
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"posReviews" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
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
         abort() causes the application to generate a crash log and terminate. 
		 You should not use this function in a shipping application, although
		 it may be useful during development. If it is not possible to recover
		 from the error, display an alert panel that instructs the user to quit 
		 the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return mFetchedResultsController;
}  


#pragma mark -
#pragma mark cleanup

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
