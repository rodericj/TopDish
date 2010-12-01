//
//  DishTableViewController.m
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DishTableViewController.h"
#import "Dish.h"
#import "Restaurant.h"
#import "NearbyMapViewController.h"
#import "SettingsViewController.h"
#import "constants.h"
#import "SBJSON.h"

@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation DishTableViewController

@synthesize bgImage;
@synthesize theSearchBar;
@synthesize theTableView;
@synthesize dishRestoSelector;
@synthesize currentLat;
@synthesize currentLon;
@synthesize currentSearchTerm;
@synthesize settingsDict;
#pragma mark -
#pragma mark View lifecycle
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"adding this didSelect");
	[theSearchBar resignFirstResponder];
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}	

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setTableHeaderView:searchHeader];
	[theSearchBar setPlaceholder:@"Search Dishes"];
	[theSearchBar setShowsCancelButton:YES];
	[theSearchBar setDelegate:self];
	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Set up the settings button
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(showSettings)];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:4] forKey:MAX_PRICE_VALUE_LOCATION];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:MIN_PRICE_VALUE_LOCATION];

	self.settingsDict = [[NSMutableDictionary alloc] init];
	
	// Set up the map button
	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)];
	
	self.navigationItem.rightBarButtonItem = mapButton;

	
	// Set up the dish/restaurant selector
	dishRestoSelector = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dishes", @"Restaurants", nil]];
	dishRestoSelector.segmentedControlStyle = UISegmentedControlStyleBar;
	dishRestoSelector.selectedSegmentIndex = 0;	

	//TODO Commented out so we don't show the selector. Add in when restaurant's are ready
	//self.navigationItem.titleView = dishRestoSelector;
	
	[dishRestoSelector addTarget:self 
						 action:@selector(initiateNetworkBasedOnSegmentControl) 
			   forControlEvents:UIControlEventValueChanged];
	
	
	[theTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
	
}

-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	conn = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE] autorelease];
	
}

-(void)initiateNetworkBasedOnSegmentControl{
	//TODO RESTODISH SWITCH - turn off the 'settings' button for restaurants

	NSLog(@"Segmentedcontrol changed");
	if([dishRestoSelector selectedSegmentIndex] == 0){
		NSLog(@"we are switching to dishes %@ %@", currentLat, currentLon);
		if (currentSearchTerm != nil) {
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000000&limit=2&q=%@", NETWORKHOST, currentLat, currentLon, [currentSearchTerm lowercaseString]]];
			
		}
		else
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000000&limit=2", NETWORKHOST, currentLat, currentLon]];
	}
	else if([dishRestoSelector selectedSegmentIndex] == 1){
		NSLog(@"we are switching to restaurants %@ %@", currentLat, currentLon);
		NSLog(@"%@", currentLat);
		[self networkQuery:[NSString stringWithFormat:@"%@/api/restaurantSearch?lat=%@&lng=%@&distance=20000", NETWORKHOST, currentLat, currentLon]];

	}
	else {
		NSLog(@"Wait...what did we just switch to?");
	}

}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"here we are using the managed Object %@", managedObject);
}

#pragma mark -
#pragma mark flip the view 
- (void) flipToMap {
	NearbyMapViewController *map = [[NearbyMapViewController alloc] initWithNibName:@"NearbyMapView" 
												 bundle:nil];
	[map setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[map setManagedObjectContext:self.managedObjectContext];
	
	NSArray *nearbyObjects = [self.fetchedResultsController fetchedObjects];
	[map setNearbyObjects:nearbyObjects];
	[nearbyObjects release];
	[self.navigationController pushViewController:map animated:TRUE];
	//[self presentModalViewController:map animated:TRUE];
}

#pragma mark -
#pragma mark Util
-(void)processIncomingNetworkText:(NSString *)responseText{
	
	//TODO RESTODISH SWITCH - when response has finised loading, I should determine if it's dishes or restauarants that I'm looking at
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSArray *responseAsArray = [parser objectWithString:responseText error:&error];	
	[parser release];
	
	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"%@", error);
	}
	
	if(responseAsArray == nil){
		NSLog(@"the response is nil");
		return;
		//responseAsArray = [self loadDummyRestaurantData];
	}
	
	if([dishRestoSelector selectedSegmentIndex] == 0){
		
		//Sort the inputted array
		NSArray *sortedDishes = [responseAsArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
			
			if ([[obj1 objectForKey:@"id"] intValue] > [[obj2 objectForKey:@"id"] intValue]) {
				return (NSComparisonResult)NSOrderedDescending;
			}
			
			if ([[obj1 objectForKey:@"id"] intValue] < [[obj2 objectForKey:@"id"] intValue]) {
				return (NSComparisonResult)NSOrderedAscending;
			}
			return (NSComparisonResult)NSOrderedSame;
		}];
		
		//TODO release dishIds and restaurantIds
		NSArray *dishIds = [self getArrayOfIdsWithArray:responseAsArray withKey:@"id"];
		NSArray *restaurantIds = [self getArrayOfIdsWithArray:responseAsArray withKey:@"restaurantID"];
		
		//Fetch the dishes
		NSFetchRequest *dishFetchRequest = [[NSFetchRequest alloc] init];
		[dishFetchRequest setEntity:
		 [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:self.managedObjectContext]];
		[dishFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(dish_id IN %@)", dishIds]];
		
		// make sure the results are sorted as well
		[dishFetchRequest setSortDescriptors: [NSArray arrayWithObject:
											   [[[NSSortDescriptor alloc] initWithKey: @"dish_id"
																			ascending:YES] autorelease]]];
		
		NSError *error;
		NSArray *dishesMatchingId = [self.managedObjectContext
									 executeFetchRequest:dishFetchRequest error:&error];
		
		[dishFetchRequest release];
		[dishIds release];
		
		NSFetchRequest *restaurantFetchRequest = [[NSFetchRequest alloc] init];
		[restaurantFetchRequest setEntity:
		 [NSEntityDescription entityForName:@"Restaurant" 
					 inManagedObjectContext:self.managedObjectContext]];
		[restaurantFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(restaurant_id IN %@)", restaurantIds]];
		[restaurantFetchRequest setSortDescriptors:[NSArray arrayWithObject:
													[[[NSSortDescriptor alloc] initWithKey:@"restaurant_id" 
																				 ascending:YES] autorelease]]];
		
		NSArray *restaurantsMatchingId = [self.managedObjectContext executeFetchRequest:restaurantFetchRequest error:&error];
		
		[restaurantIds release];
		[restaurantFetchRequest release];
		
		int existingDishCounter = 0;
		int existingRestoCounter = 0;
		for (int incomingCounter =0; incomingCounter < [sortedDishes count]; incomingCounter++){
			NSDictionary *newElement = [sortedDishes objectAtIndex:incomingCounter];
			Dish *existingDish; 
			Restaurant *thisRestaurant; 
			if (existingDishCounter >= [dishesMatchingId count]){
				existingDish = nil;
			}
			else{
				existingDish = [dishesMatchingId objectAtIndex:existingDishCounter];
			}			
			
			
			if([[newElement objectForKey:@"id"] intValue] != [[existingDish dish_id] intValue]){
				NSDictionary *thisElement = [sortedDishes objectAtIndex:incomingCounter];
				Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
																	   inManagedObjectContext:self.managedObjectContext];
				if (existingRestoCounter >= [restaurantsMatchingId count]){
					thisRestaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																				 inManagedObjectContext:self.managedObjectContext];
					NSNumber *restaurant_id = [thisElement objectForKey:@"restaurantID"];
					
					[thisRestaurant setRestaurant_id:restaurant_id];
					[thisRestaurant setObjName:[thisElement objectForKey:@"restaurantName"]];
				}
				else{
					thisRestaurant = [restaurantsMatchingId objectAtIndex:existingRestoCounter];
				}
				
				[thisDish setDish_id:[thisElement objectForKey:@"id"]];
				[thisDish setObjName:[thisElement objectForKey:@"name"]];
				[thisDish setPrice:[NSNumber numberWithInt:(incomingCounter%4)+1]];
				[thisDish setDish_description:[thisElement objectForKey:@"description"]];
				[thisDish setPhotoURL:[NSString stringWithFormat:@"%@%@", NETWORKHOST, 
									   [thisElement objectForKey:@"photoURL"]]];
				[thisDish setRestaurant:thisRestaurant];
				[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
				[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
				[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
				[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
				[thisDish setDish_id:[thisElement objectForKey:@"id"]];
				
				[thisDish setDistance:[self calculateDishDistance:(id *)thisDish]];
			}
			else{
				existingDishCounter++;
			}
			
			
		}
		
	}
	else if([dishRestoSelector selectedSegmentIndex] == 1){
		
		for (int i =0; i < [responseAsArray count]; i++){
			Restaurant *thisResto = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" inManagedObjectContext:self.managedObjectContext];
			NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
			NSLog(@"%@ %@", [thisElement objectForKey:@"id"], [thisElement objectForKey:@"restaurantName"]);
			//[thisDish setDish_id:[thisElement objectForKey:@"id"]];
			//			[thisDish setDish_name:[thisElement objectForKey:@"name"]];
		}
		
	}
	
	//TODO save all of the dishes or restaurants created here
	if(![self.managedObjectContext save:&error]){
		NSLog(@"there was an error when saving");
		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	
	[fetchRequest setEntity:entity];
	
	[fetchRequest release];	
	
	[responseText release];
	[_responseData release];
	_responseData = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(NSArray *)getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString *)key{
	NSEnumerator *enumerator = [responseAsArray objectEnumerator];
	id anObject;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	while (anObject = (NSDictionary *)[enumerator nextObject]){
		[ret addObject:[anObject objectForKey:key]];
	}
	//NSLog(@"At the end of all that, the return is %@", ret);
	[ret sortUsingSelector:@selector(compare:)];
	return ret;
}

- (void) showSettings{
	SettingsView *settings = [[SettingsView alloc] initWithNibName:@"SettingsView" 
																			 bundle:nil];
	[settings setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	
	[self presentModalViewController:settings animated:TRUE];
	[settings setDelegate:self];
}
	 
-(void) updateFetch{

	NSNumber *min = [[NSUserDefaults standardUserDefaults] objectForKey:MIN_PRICE_VALUE_LOCATION];
	NSNumber *max = [[NSUserDefaults standardUserDefaults] objectForKey:MAX_PRICE_VALUE_LOCATION];
	
	//TODO....Ok this should all be in a function somewhere.
	//Create array with sort params, then store in NSUserDefaults
	NSNumber *selectedIndex = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION];
	NSString *sorter = [[NSArray arrayWithObjects:RATINGS_SORT, DISTANCE_SORT, nil] objectAtIndex:[selectedIndex intValue]];

	/*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
	NSPredicate *filterPredicate;
	NSLog(@"current search term %@", currentSearchTerm);
	if (currentSearchTerm && [currentSearchTerm length] > 0) {
		
		NSString *attributeName = @"objName";
		NSString *attributeValue = currentSearchTerm;
		NSLog(@"the predicate we are sending: %@ contains(cd) %@ AND %@ <= %@ AND %@ >= %@",
			  attributeName, attributeValue,
			  @"price", max, 
			  @"price", min);
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@ AND %K <= %@ AND %K >= %@",
										attributeName, attributeValue,
										@"price", max, 
										@"price", min];
		
		NSLog(@"the real predicate is %@", filterPredicate);
	}
	else {
		NSLog(@"the else predicate %K <= %@ AND %K >= %@", 
			  @"price", max, 
			  @"price", min);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K <= %@ AND %K >= %@", 
								@"price", max, 
								@"price", min];
		
	}

		
	[fetchRequest setPredicate:filterPredicate];
	
	// Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
	NSLog(@"sorting ascending %d", [selectedIndex intValue]==0);
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter ascending:[selectedIndex intValue]==1];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
   // NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    [currentSearchTerm release];
	currentSearchTerm = nil;
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         //TODO remove auto generated abort
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	[self.tableView reloadData];

}


- (NSNumber *) calculateDishDistance:(id *)dish{
	Dish *thisDish = (Dish *)dish;
	double a = [currentLat doubleValue];
	double b = [[thisDish latitude] doubleValue];
	double c = (a-b)*(a-b);
	a = [currentLon doubleValue];
	b = [[thisDish longitude] doubleValue];
	double d = (a-b)*(a-b);
	NSLog(@"%f %f",c, d);
	
	NSNumber *ret = [[[NSNumber alloc] initWithDouble:d] autorelease];
	
	return ret;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	NSLog(@"the search bar text changed %@", searchText);
	
	//Send the network request
	currentSearchTerm = searchText;
	[currentSearchTerm retain];
	[self initiateNetworkBasedOnSegmentControl];
	
	//Limit the core data output
	[self updateFetch];
}


#pragma mark -
#pragma mark Table view data source


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}
 

#pragma mark -
#pragma mark Location
- (void)locationError:(CLLocation *)location {
	NSLog(@"Error getting location");
}
	
- (void)locationUpdate:(CLLocation *)location {
	
	[self getNearbyItems:location];
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	//[locationController.locationManager stopUpdatingLocation];
}

- (void)getNearbyItems:(CLLocation *)location {
	NSLog(@"getNearbyItems Called %@. Accuracy: %d, %d", [location description], location.verticalAccuracy, location.horizontalAccuracy);
	
	if (location == NULL){
		NSLog(@"the location was null which means that the thread is doing something intersting. Lets send this back.");
	}
	else{
		//Make location string 2 separate lat/long
		NSString *latlong = [[[location description] stringByReplacingOccurrencesOfString:@"<" withString:@""] 
							 stringByReplacingOccurrencesOfString:@">" withString:@""];
		NSLog(@"the latlong is %@", latlong);
		NSArray *chunks = [latlong componentsSeparatedByString:@" "];
		if (currentLat != nil) {
			[currentLat release];
		}
		if (currentLon != nil){
			[currentLat release];
		}
		currentLat =[[[chunks objectAtIndex:0] stringByReplacingOccurrencesOfString:@"," withString:@""] copy];
		currentLon = [[chunks objectAtIndex:1] copy];
		[self initiateNetworkBasedOnSegmentControl];
		
	}
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
	[settingsDict release];
    [super dealloc];
}


@end

