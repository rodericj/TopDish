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
#import "AppModel.h"

#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]
#define buttonLightBlue [UIColor colorWithRed:0 green:.73 blue:.89 alpha:1 ]
#define buttonLightBlueShine [UIColor colorWithRed:.53 green:.91 blue:.99 alpha:1]

#define sortStringArray [NSArray arrayWithObjects:DISTANCE_SORT, RATINGS_SORT, PRICE_SORT, nil]
@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation DishTableViewController

@synthesize bgImage = mBgImage;
@synthesize theSearchBar = mTheSearchBar;
@synthesize dishRestoSelector = mDishRestoSelector;
@synthesize currentLat = mCurrentLat;
@synthesize currentLon = mCurrentLon;
@synthesize currentSearchTerm = mCurrentSearchTerm;
@synthesize settingsDict = mSettingsDict;
@synthesize searchHeader = mSearchHeader;
@synthesize rltv = mrltv;
//@synthesize entityTypeString = mEntityTypeString;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;
	self.tableView.backgroundColor = kTopDishBackground;
	self.entityTypeString = @"Dish";

    [super viewDidLoad];
	[self.tableView setTableHeaderView:self.searchHeader];
	self.tableView.delegate = self;
	
	self.navigationController.navigationBar.tintColor = kTopDishBlue;
//	myBar.tintColor = [UIColor greenColor];
	
	[self.theSearchBar setPlaceholder:@"Search Dishes"];
	[self.theSearchBar setShowsCancelButton:YES];
	[self.theSearchBar setDelegate:self];
	[self.theSearchBar setTintColor:kTopDishBlue];
	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	
    // Set up the settings button
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:FILTER_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(showSettings)];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	self.settingsDict = [[NSMutableDictionary alloc] init];
	
	// Set up the map button
	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:GLOBAL_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)];
	
	self.navigationItem.rightBarButtonItem = mapButton;

	
	// Set up the dish/restaurant selector
	self.dishRestoSelector = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dishes", 
																   @"Restaurants", 
																   nil]];
	[self.dishRestoSelector setSegmentedControlStyle:UISegmentedControlStyleBar];
	[self.dishRestoSelector setSelectedSegmentIndex:0];
	[self.dishRestoSelector setTintColor:buttonLightBlue];
	
	self.navigationItem.titleView = self.dishRestoSelector;
	
	[self.dishRestoSelector addTarget:self 
						 action:@selector(initiateNetworkBasedOnSegmentControl) 
			   forControlEvents:UIControlEventValueChanged];
	
	
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
	
}

-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	//NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	self.conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
	
}

-(void)initiateNetworkBasedOnSegmentControl{
	//TODO RESTODISH SWITCH - turn off the 'settings' button for restaurants

	NSLog(@"Segmentedcontrol changed");
	if([self.dishRestoSelector selectedSegmentIndex] == 0){
		//self.fetchedResultsController = nil;
		self.entityTypeString = @"Dish";
		if (self.currentSearchTerm != nil) {
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000&limit=2&q=%@",
								NETWORKHOST,self.currentLat,
								self.currentLon, 
								[self.currentSearchTerm lowercaseString]]];
		}
		else
			[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=200000&limit=2", 
								NETWORKHOST, self.currentLat, self.currentLon]];
		
		[self.tableView setDataSource:self];
	}
	else if([self.dishRestoSelector selectedSegmentIndex] == 1){
		NSLog(@"rltv is %@", self.rltv);
		if(!self.rltv){
			self.rltv = [[RestaurantListTableViewDelegate alloc] init];
			[self.rltv setEntityTypeString:@"Restaurant"];
			[self.rltv setManagedObjectContext:self.managedObjectContext];
		}
		
		[self.tableView setDataSource:self.rltv];
	}
	else {
		NSLog(@"Wait...what did we just switch to?");
	}
	[self.tableView reloadData];
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//do we need to update the fetch when we come back?
	if ([self.dishRestoSelector selectedSegmentIndex] == 0) {
		[self updateFetch];
	}
	//[self updateFetch];
	NSLog(@"filter on these %d, %d", [[AppModel instance] selectedMealType], [[AppModel instance] selectedPrice]);
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"here we are using the managed Object %@", managedObject);
}

#pragma mark -
#pragma mark flip the view 
- (void) flipToMap {
	NearbyMapViewController *map = [[NearbyMapViewController alloc] 
									initWithNibName:@"NearbyMapView" 
												 bundle:nil];
	[map setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[map setManagedObjectContext:self.managedObjectContext];
	
	NSArray *nearbyObjects = [self.fetchedResultsController fetchedObjects];
	[map setNearbyObjects:nearbyObjects];
	[self.navigationController pushViewController:map animated:TRUE];
	[map release];
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
	
	//If we are showing restaurants
	if([self.dishRestoSelector selectedSegmentIndex] == 0){
		
		//TODO remove blocks for backwards compatibility beyond iOS 4.2(?)
		//Sort the inputted array
		NSArray *sortedDishesFromApi = [responseAsArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
			
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
											   [NSSortDescriptor 
												sortDescriptorWithKey:@"dish_id" 																			
												ascending:YES]]];
		NSError *error;
		NSArray *dishesMatchingId = [self.managedObjectContext
									 executeFetchRequest:dishFetchRequest error:&error];
		
		[dishFetchRequest release];
		
		NSFetchRequest *restaurantFetchRequest = [[NSFetchRequest alloc] init];
		[restaurantFetchRequest setEntity:
		 [NSEntityDescription entityForName:@"Restaurant" 
					 inManagedObjectContext:self.managedObjectContext]];
		[restaurantFetchRequest setPredicate:[NSPredicate 
											  predicateWithFormat:@"(restaurant_id IN %@)", 
											  restaurantIds]];
		
		[restaurantFetchRequest setSortDescriptors:[NSArray arrayWithObject:
													[NSSortDescriptor 
													 sortDescriptorWithKey:@"restaurant_id"
													 ascending:YES]]];
		
		NSArray *restaurantsMatchingId = [self.managedObjectContext executeFetchRequest:restaurantFetchRequest error:&error];
		
		[restaurantFetchRequest release];
		
		int existingDishCounter = 0;
		int existingRestoCounter = 0;
		for (int incomingCounter = 0; incomingCounter < [sortedDishesFromApi count]; incomingCounter++){
			NSDictionary *newElement = [sortedDishesFromApi objectAtIndex:incomingCounter];
			Dish *thisDish; 
			Restaurant *thisRestaurant; 
			if (existingDishCounter >= [dishesMatchingId count]){
				thisDish = nil;
			}
			else{
				thisDish = [dishesMatchingId objectAtIndex:existingDishCounter];
			}			
			NSDictionary *thisElement = [sortedDishesFromApi objectAtIndex:incomingCounter];

			//if the element we are looking at is not the current existing dish then we need to create a new one
			if([[newElement objectForKey:@"id"] intValue] != [[thisDish dish_id] intValue]){
				//We've never seen this dish, so create it
				thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
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
				
				NSArray *tagsArray = [thisElement objectForKey:@"tags"];
				for (NSDictionary *tag in tagsArray){
					if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kMealTypeString] )
						[thisDish setMealType:[tag objectForKey:@"id"]];
					if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kPriceTypeString] )						
						[thisDish setPrice:[tag objectForKey:@"id"]];
				}
				
				//These will only change when it is a new dish
				[thisDish setRestaurant:thisRestaurant];
				[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
				[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
				[thisDish setDish_id:[thisElement objectForKey:@"id"]];
				[thisDish setObjName:[thisElement objectForKey:@"name"]];
				
				//[thisDish setPrice:[NSNumber numberWithInt:(incomingCounter%4)+1]];

			}
			else{
				existingDishCounter++;
			}

			//These will most likely change nearly every time, so we do this fo
			//both new and existing dishes
			[thisDish setDish_description:[thisElement objectForKey:@"description"]];
			[thisDish setPhotoURL:[thisElement objectForKey:@"photoURL"]];
			
			[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
			[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
			
			[thisDish setDistance:[self calculateDishDistance:(id *)thisDish]];
			float pos = [[thisElement objectForKey:@"posReviews"] intValue];
			float neg = [[thisElement objectForKey:@"negReviews"] intValue];
			[thisDish setCalculated_rating:[NSNumber numberWithInt:(int)(pos/(pos+neg)*100)]];
			
		}
		
	}
	else if([self.dishRestoSelector selectedSegmentIndex] == 1){
		
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
	
	//TODO again, this fetch happend and I don't know why
	//NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
//											  inManagedObjectContext:self.managedObjectContext];
//	
//	[fetchRequest setEntity:entity];
//	
//	[fetchRequest release];	
	self.responseData = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(NSArray *)getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString *)key{
	NSEnumerator *enumerator = [responseAsArray objectEnumerator];
	id anObject;
	NSMutableArray *ret = [NSMutableArray array];
	while (anObject = (NSDictionary *)[enumerator nextObject]){
		[ret addObject:[anObject objectForKey:key]];
	}
	//NSLog(@"At the end of all that, the return is %@", ret);
	[ret sortUsingSelector:@selector(compare:)];
	return ret;
}

- (void) showSettings {
	SettingsView1 *settings = [[SettingsView1 alloc] initWithNibName:@"SettingsView1" bundle:nil];
	[settings setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[self.navigationController pushViewController:settings animated:TRUE];
	[settings release];
}

-(void) populatePredicateArray:(NSMutableArray *)filterPredicateArray{
	NSPredicate *filterPredicate;

	//Filter based on search
	if (self.currentSearchTerm && [self.currentSearchTerm length] > 0) {
		
		NSString *attributeName = @"objName";
		NSString *attributeValue = self.currentSearchTerm;
		NSLog(@"the predicate we are sending: %@ contains(cd) %@ AND %@ == %d",
			  attributeName, attributeValue,
			  @"price", [[AppModel instance] selectedPrice]);
		
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",
						   attributeName, attributeValue];
		
		NSLog(@"the real predicate is %@", filterPredicate);
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on price
	if ([[AppModel instance] selectedPrice] != 0) {
		
		
		NSLog(@"the else predicate %@ == %d", 
			  @"price", [[AppModel instance] selectedPrice]);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"price", [NSNumber numberWithInt:[[AppModel instance] selectedPrice]]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on mealType
	if ([[AppModel instance] selectedMealType] != 0) {
		NSLog(@"the else predicate %@ == %d", 
			  @"price", [[AppModel instance] selectedPrice]);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"mealType", [NSNumber numberWithInt:[[AppModel instance] selectedMealType]]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
}
-(void) updateFetch {
	
	/*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    // Edit the entity name as appropriate.
	NSLog(@"entity type string %@", self.entityTypeString);

    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityTypeString 
											  inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
	//Set up the filters that are stored in the AppModel
	NSMutableArray *filterPredicateArray = [NSMutableArray array];
	
	[self populatePredicateArray:filterPredicateArray];
	
	NSPredicate *fullPredicate = [NSCompoundPredicate 
								  andPredicateWithSubpredicates:filterPredicateArray]; 
	[fetchRequest setPredicate:fullPredicate];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
    
	//Create array with sort params, then store in NSUserDefaults
	NSString *sorter = [sortStringArray objectAtIndex:[[AppModel instance] sorter]];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:sorter 
								ascending:FALSE];
	
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	self.fetchedResultsController = nil;

    NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:self.managedObjectContext 
										  sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    //[currentSearchTerm release];
	//self.currentSearchTerm = nil;
    NSError *error = nil;
    if (![mFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	//Finally, reload the data with the latest fetch
	[self.tableView reloadData];

}


- (NSNumber *) calculateDishDistance:(id *)dish{
	Dish *thisDish = (Dish *)dish;
	double a = [self.currentLat doubleValue];
	double b = [[thisDish latitude] doubleValue];
	a = [self.currentLon doubleValue];
	b = [[thisDish longitude] doubleValue];
	double d = (a-b)*(a-b);
	
	NSNumber *ret = [NSNumber numberWithDouble:d];
	return ret;
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
	[self.theSearchBar resignFirstResponder];
	ObjectWithImage *selectedObject;
	//self.fetchedResultsController = nil;

	if([self.dishRestoSelector selectedSegmentIndex] == 0){
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


-(IBAction) sortByDistance
{
	NSLog(@"sort by distance");
	[[AppModel instance] setSorter:kSortByDistance];
	[self updateFetch];
}
-(IBAction) sortByRating
{
	NSLog(@"sort by Rating");
	[[AppModel instance] setSorter:kSortByRating];
	[self updateFetch];
}
-(IBAction) sortByPrice
{
	NSLog(@"sort by Price");
	[[AppModel instance] setSorter:kSortByPrice];
	[self updateFetch];
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
		if (self.currentLat != nil) {
			self.currentLat = nil;
		}
		if (self.currentLon != nil){
			self.currentLon = nil;
		}
		self.currentLat =[[[chunks objectAtIndex:0] stringByReplacingOccurrencesOfString:@"," withString:@""] copy];
		self.currentLon = [[chunks objectAtIndex:1] copy];
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
#pragma mark Search delegate functions

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	[self updateFetch];
}	

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	NSLog(@"the search bar text changed %@", searchText);
	
	//Send the network request
	self.currentSearchTerm = searchText;
	[self initiateNetworkBasedOnSegmentControl];
	
	//Limit the core data output
	[self updateFetch];
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
    //self.mFetchedResultsController = nil;
    self.managedObjectContext = nil;
	self.settingsDict = nil;
    [super dealloc];
}


@end

