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
#import "constants.h"
#import "SBJSON.h"
#import "SettingsView1.h"

#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]

@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation DishTableViewController

@synthesize bgImage;
@synthesize theSearchBar;
@synthesize dishRestoSelector;
@synthesize currentLat;
@synthesize currentLon;
@synthesize currentSearchTerm;
@synthesize settingsDict;
@synthesize searchHeader;
@synthesize rltv = mrltv;
//@synthesize entityTypeString = mEntityTypeString;
#pragma mark -
#pragma mark View lifecycle
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	[self.tableView reloadData];
}	

- (void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;
	self.tableView.backgroundColor = kTopDishBackground;
	self.entityTypeString = @"Dish";

    [super viewDidLoad];
	[self.tableView setTableHeaderView:searchHeader];
	self.tableView.delegate = self;
	
	self.navigationController.navigationBar.tintColor = kTopDishBlue;
//	myBar.tintColor = [UIColor greenColor];
	
	[theSearchBar setPlaceholder:@"Search Dishes"];
	[theSearchBar setShowsCancelButton:YES];
	[theSearchBar setDelegate:self];
	[theSearchBar setTintColor:kTopDishBlue];
	
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
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:SORT_VALUE_LOCATION];

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
	
	self.navigationItem.titleView = dishRestoSelector;
	
	[dishRestoSelector addTarget:self 
						 action:@selector(initiateNetworkBasedOnSegmentControl) 
			   forControlEvents:UIControlEventValueChanged];
	
	
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
	
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
		self.fetchedResultsController = nil;
		self.entityTypeString = @"Dish";
		if (currentSearchTerm != nil) {
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000&limit=2&q=%@", NETWORKHOST, currentLat, currentLon, [currentSearchTerm lowercaseString]]];
			
		}
		else
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000&limit=2", NETWORKHOST, currentLat, currentLon]];
		
		[self.tableView setDataSource:self];
	}
	else if([dishRestoSelector selectedSegmentIndex] == 1){
		NSLog(@"we are switching to restaurants %@ %@", currentLat, currentLon);
		NSLog(@"rltv is %@", self.rltv);
		if(!self.rltv){
			self.rltv = [[RestaurantListTableViewDelegate alloc] init];
			[self.rltv setEntityTypeString:@"Restaurant"];
			[self.rltv setManagedObjectContext:self.managedObjectContext];
		}
		
		[self.tableView setDataSource:self.rltv];
		//[self networkQuery:[NSString stringWithFormat:@"%@/api/restaurantSearch?lat=%@&lng=%@&distance=20000", NETWORKHOST, currentLat, currentLon]];
	}
	else {
		NSLog(@"Wait...what did we just switch to?");
	}
	[self.tableView reloadData];
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
		for (int incomingCounter = 0; incomingCounter < [sortedDishes count]; incomingCounter++){
			NSDictionary *newElement = [sortedDishes objectAtIndex:incomingCounter];
			Dish *existingDish; 
			Restaurant *thisRestaurant; 
			if (existingDishCounter >= [dishesMatchingId count]){
				existingDish = nil;
			}
			else{
				existingDish = [dishesMatchingId objectAtIndex:existingDishCounter];
			}			
			
			//if the element we are looking at is not the current existing dish then we need to create a new one
			if([[newElement objectForKey:@"id"] intValue] != [[existingDish dish_id] intValue]){
				//We've never seen this dish, so create it
				NSDictionary *thisElement = [sortedDishes objectAtIndex:incomingCounter];
				Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
																	   inManagedObjectContext:self.managedObjectContext];
				
				
				if (existingRestoCounter >= [restaurantsMatchingId count]){
					thisRestaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																				 inManagedObjectContext:self.managedObjectContext];
					NSLog(@"adding %@", [thisElement objectForKey:@"restaurantID"]);
					NSNumber *restaurant_id = [thisElement objectForKey:@"restaurantID"];
					
					[thisRestaurant setRestaurant_id:restaurant_id];
					[thisRestaurant setObjName:[thisElement objectForKey:@"restaurantName"]];
				}
				else{
					thisRestaurant = [restaurantsMatchingId objectAtIndex:existingRestoCounter];
					
					BOOL foundRestaurantInCoreDataForThisDish = FALSE;
					//Then from the object determine if this restaurant is in the restaurantsMatchingId array
					for (int i = existingRestoCounter; i < [restaurantsMatchingId count]; i++) {
						NSNumber *restaurantID = [restaurantsMatchingId objectAtIndex:i];
						if (restaurantID == [[thisDish restaurant] restaurant_id]) {
							//set thisDish's restaurant to restaurantID
							//set flag saying we've set the restaurant
							foundRestaurantInCoreDataForThisDish = YES;
						}
					}
					if (!foundRestaurantInCoreDataForThisDish) {
						//create a new restaurant with this id and [thisElement objectForKey:@"restaurantName"]
						thisRestaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																					 inManagedObjectContext:self.managedObjectContext];
						NSLog(@"adding %@", [thisElement objectForKey:@"restaurantID"]);
						NSNumber *restaurant_id = [thisElement objectForKey:@"restaurantID"];
						
						[thisRestaurant setRestaurant_id:restaurant_id];
						[thisRestaurant setObjName:[thisElement objectForKey:@"restaurantName"]];
					}
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
			//Restaurant *thisResto = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" inManagedObjectContext:self.managedObjectContext];
			NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
			NSLog(@"elemented at id: %@\nresto name: %@", [thisElement objectForKey:@"id"], [thisElement objectForKey:@"restaurantName"]);
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
	SettingsView1 *settings = [[SettingsView1 alloc] initWithNibName:@"SettingsView1" bundle:nil];
	//SettingsTableView *settings = [[SettingsTableView alloc] initWithStyle:UITableViewStyleGrouped];

	//SettingsView *settings = [[SettingsView alloc] initWithNibName:@"SettingsView" bundle:nil];
	[settings setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	
	[self.navigationController pushViewController:settings animated:TRUE];
	//[self presentModalViewController:settings animated:TRUE];
//	[settings setDelegate:self];
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
	NSLog(@"entity type string %@", self.entityTypeString);

    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityTypeString inManagedObjectContext:self.managedObjectContext];
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
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}
 
#pragma mark -
#pragma mark Table view data delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"adding this didSelect");
	[theSearchBar resignFirstResponder];
	ObjectWithImage *selectedObject;
	self.fetchedResultsController = nil;

	if([dishRestoSelector selectedSegmentIndex] == 0){
		self.entityTypeString = @"Dish";
		selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		[self pushDishViewController:selectedObject];
	}
	else {
		self.entityTypeString = @"Restaurant";
		selectedObject = [[self.rltv fetchedResultsController] objectAtIndexPath:indexPath];
		[self pushRestaurantViewController:selectedObject];
	}
	//[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Location
- (void)locationError:(NSError *)error {
	NSLog(@"Error getting location %@", error);
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
			currentLat = nil;
		}
		if (currentLon != nil){
			currentLon = nil;
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

