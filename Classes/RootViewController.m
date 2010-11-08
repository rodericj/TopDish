//
//  RootViewController.m
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Dish.h"
#import "Restaurant.h"
#import "asyncimageview.h"
#import "NearbyMapViewController.h"
#import "SettingsViewController.h"
#import "ScrollingDishDetailViewController.h"
#import "constants.h"
#import "SBJSON.h"

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation RootViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize tvCell;
@synthesize bgImage;
@synthesize theSearchBar;
@synthesize theTableView;
@synthesize _responseText;
@synthesize dishRestoSelector;
@synthesize currentLat;
@synthesize currentLon;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];	
	
	//The first time this view loads it will always be a dish Search 37.958, -121.998
	//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishSearch?lat=33.6886&lng=-117.8129&disance=2000", NETWORKHOST]];
	//NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishSearch?lat=37.958&lng=-121.998&disance=2000000", NETWORKHOST]];
	//Start up the networking
	//NSURLRequest *request = [NSURLRequest requestWithURL:url];
	//NSURLRequest *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	//[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Set up the settings button
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(showSettings)];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	
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
	conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	//[conn release];
	
}
-(void)initiateNetworkBasedOnSegmentControl{
	//TODO RESTODISH SWITCH - turn off the 'settings' button for restaurants

	NSLog(@"Segmentedcontrol changed");
	if([dishRestoSelector selectedSegmentIndex] == 0){
		NSLog(@"we are switching to dishes %@ %@", currentLat, currentLon);
		[self networkQuery:[NSString stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=20000&limit=5", NETWORKHOST, currentLat, currentLon]];
		//url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishSearch?lat=33.6886&lng=-117.8129&disance=2000", NETWORKHOST]];
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
#pragma mark Bring up the Settings view
- (void) showSettings{
	SettingsView *settings = [[SettingsView alloc] initWithNibName:@"SettingsView" 
																			 bundle:nil];
	[settings setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	
	[self presentModalViewController:settings animated:TRUE];
	[settings setDelegate:self];
}
	 
-(void) updateSettings:(NSDictionary *)settings{

	NSNumber *min = [[NSUserDefaults standardUserDefaults] objectForKey:MIN_PRICE_VALUE_LOCATION];
	NSNumber *max = [[NSUserDefaults standardUserDefaults] objectForKey:MAX_PRICE_VALUE_LOCATION];
	NSPredicate *filterPricePredicate = [NSPredicate predicateWithFormat: @"%K <= %@ AND %K >= %@", 
										 @"price", max, 
										 @"price", min];
	
	
	
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
    
	[fetchRequest setPredicate:filterPricePredicate];
	
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
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

#pragma mark -
#pragma mark Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return COMMENTTABLECELLHEIGHT;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
	//return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"row number %d", [indexPath row]);

	//TODO RESTODISH SWITCH - Show a different cell for restaurants vs dishs

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RootControllerTableViewCell" owner:self options:nil];
		cell = tvCell;
	}
		
	//Query the results controller
	Dish *thisDish = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	
	//Build the UIElements
    UILabel *dishName;
	dishName = (UILabel *)[cell viewWithTag:ROOTVIEW_DISH_NAME_TAG];
	dishName.text = thisDish.dish_name;
	
	UILabel *resto;
	resto = (UILabel *)[cell viewWithTag:ROOTVIEW_RESTAURANT_NAME_TAG];
	resto.text = @"Resto Name";
	
	UILabel *cost;
	cost = (UILabel *)[cell viewWithTag:ROOTVIEW_COST_TAG];
	cost.text = @"$$$";
	
	UILabel *upVotes;
	upVotes = (UILabel *)[cell viewWithTag:ROOTVIEW_UPVOTES_TAG];
	upVotes.text = [NSString stringWithFormat:@"%@", 
					[thisDish posReviews]];
	
	UILabel *downVotes;
	downVotes = (UILabel *)[cell viewWithTag:ROOTVIEW_DOWNVOTES_TAG];
	downVotes.text = [NSString stringWithFormat:@"%@", 
					  [thisDish negReviews]];
	
	UILabel *priceNumber;
	priceNumber = (UILabel *)[cell viewWithTag:ROOTVIEW_COST_TAG];
	
	NSMutableString *output = [NSMutableString stringWithCapacity:[[thisDish price] intValue]];
	
	for (int i = 0; i < [[thisDish price] intValue]; i++)
		[output appendString:@"$"];
	priceNumber.text = output;
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:ROOTVIEW_IMAGE_TAG];

	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[imageView frame]];
	asyncImage.tag = 999;
	if( [[thisDish dish_photoURL] length] > 0 ){
		NSString *urlString = [NSString stringWithFormat:@"%@&w=70&h=70", [thisDish dish_photoURL]];
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		[asyncImage loadImageFromURL:photoUrl withImageView:imageView showActivityIndicator:FALSE];
		[cell.contentView addSubview:asyncImage];
	}
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
//    }
	[cell setOpaque:FALSE];
    return cell;
}



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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO RESTODISH SWITCH - The drilldown for restaurants and dishes are different in the detailviewcontroller

    // Navigation logic may go here -- for example, create and push another view controller.
	Dish *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSLog(@"DishName from RootView Controller %@", [selectedObject dish_name]);
	
	ScrollingDishDetailViewController *detailViewController = [[ScrollingDishDetailViewController alloc] initWithNibName:@"ScrollingDishDetailView" bundle:nil];

	[detailViewController setDish:selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];

	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
     
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"posReviews" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
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
    
    return fetchedResultsController_;
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
#pragma mark Network Delegate 
- (NSArray *)loadDummyRestaurantData{
	NSString *restoJsonData = @"[\
	{\
	\"id\":138,\
	\"restaurantName\":\"The Burger Joint\",\
	\"addressLine1\":\"123 main street\",\
	\"addressLine2\":\"\",\
	\"city\":34,\
	\"state\":12,\
	\"neighborhood\":\"pac Heights\"\
	},\
	{\
	\"id\":139,\
	\"restaurantName\":\"The Burger Joint\",\
	\"addressline1\":\"123 main street\",\
	\"addressLine2\":\"\",\
	\"city\":\"San Francisco\",\
	\"state\":\"CA\",\
	\"neighborhood\":\"Nob Hill\"\
	}]";
	SBJSON *parser = [SBJSON new];
	parser = [SBJSON new];
	NSArray *responseAsArray = [parser objectWithString:restoJsonData error:NULL];
	[parser release];
	return responseAsArray;
}
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"connection did finish loading");
	NSString *responseText = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
	NSLog(@"response Text %@", responseText);
	//TODO RESTODISH SWITCH - when response has finised loading, I should determine if it's dishes or restauarants that I'm looking at

	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSArray *responseAsArray = [parser objectWithString:responseText error:&error];	
	[parser release];

	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"%@", error);
		NSLog(@"the text %@", responseText);
		NSLog(@"the raw data %@", _responseText);
	}

	if(responseAsArray == nil){
		NSLog(@"the response is nil");
		responseAsArray = [self loadDummyRestaurantData];
	}
	[self.managedObjectContext reset];
	
	if([dishRestoSelector selectedSegmentIndex] == 0){
		
		//Sort the inputted array
		NSArray *sortedArray = [responseAsArray sortedArrayUsingComparator: ^(id obj1, id obj2) {

			if ([[obj1 objectForKey:@"id"] intValue] > [[obj2 objectForKey:@"id"] intValue]) {
				return (NSComparisonResult)NSOrderedDescending;
			}
			
			if ([[obj1 objectForKey:@"id"] intValue] < [[obj2 objectForKey:@"id"] intValue]) {
				return (NSComparisonResult)NSOrderedAscending;
			}
			return (NSComparisonResult)NSOrderedSame;
		}];

		NSArray *ids = [self getArrayOfIdsWithArray:responseAsArray];
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:
		 [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:self.managedObjectContext]];
		[fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"(dish_id IN %@)", ids]];
		
		// make sure the results are sorted as well
		[fetchRequest setSortDescriptors: [NSArray arrayWithObject:
										   [[[NSSortDescriptor alloc] initWithKey: @"dish_id"
																		ascending:YES] autorelease]]];
		
		NSError *error;
		NSArray *dishesMatchingId = [self.managedObjectContext
										   executeFetchRequest:fetchRequest error:&error];
					
		int j = 0;
		for (int i =0; i < [sortedArray count]; i++){
			NSLog(@"checking all of the elements we just got");
			NSDictionary *newElement = [sortedArray objectAtIndex:i];
			Dish *existingDish; 
			if (j >= [dishesMatchingId count]){
				existingDish = nil;
			}
			else{
				existingDish = [dishesMatchingId objectAtIndex:j];
			}
			if([[newElement objectForKey:@"id"] intValue] != [[existingDish dish_id] intValue]){
				NSDictionary *thisElement = [sortedArray objectAtIndex:i];
				Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
																	   inManagedObjectContext:self.managedObjectContext];
				[thisDish setDish_id:[thisElement objectForKey:@"id"]];
				[thisDish setDish_name:[thisElement objectForKey:@"name"]];
				[thisDish setPrice:[NSNumber numberWithInt:(i%4)+1]];
				[thisDish setDish_description:[thisElement objectForKey:@"description"]];
				[thisDish setDish_photoURL:[NSString stringWithFormat:@"%@%@", NETWORKHOST, 
											[thisElement objectForKey:@"photoURL"]]];
				//[thisDish setRestaurant:<#(Restaurant *)#>
				[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
				[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
				[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
				[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
				[thisDish setDish_id:[thisElement objectForKey:@"id"]];
				
				[thisDish setDistance:[self calculateDishDistance:(id *)thisDish]];
				NSLog(@"the distance of this dish is %@", [thisDish distance]);

				//NSLog(@"saving %@", self.managedObjectContext);
//				if (![self.managedObjectContext save:&error]){
//					NSLog(@"there was an error when saving");
//					NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
//				}
//				NSLog(@"done saving");
			}
			else{
				NSLog(@"no need to create the dish %@", [existingDish dish_id]);
				j++;
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
//	if(![self.managedObjectContext save:&error]){
//		NSLog(@"there was an error when saving");
//		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
//	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	
	[fetchRequest setEntity:entity];
	
	[fetchRequest release];	
	
	[responseText release];
	[_responseText release];
	_responseText = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"connection did fail with error %@", error);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSLog(@"connectin did receive data");
	NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"this segment of data is %@", responseText);
	[responseText release];
	if(_responseText == nil){
		NSLog(@"must be the first time we got data, had to initialize it here");
		//_responseText = [[NSData alloc] initWithData:data];
		_responseText = [[NSMutableData alloc] initWithData:data];
	}
	else{
		[_responseText appendData:data];
	}
}

	
-(NSArray *)getArrayOfIdsWithArray:(NSArray *)responseAsArray{
	NSEnumerator *enumerator = [responseAsArray objectEnumerator];
	id anObject;
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	while (anObject = (NSDictionary *)[enumerator nextObject]){
		[ret addObject:[anObject objectForKey:@"id"]];
	}
	NSLog(@"At the end of all that, the return is %@", ret);
	[ret sortUsingSelector:@selector(compare:)];
	return ret;
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
    [super dealloc];
}


@end

