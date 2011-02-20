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
#import "asyncimageview.h"
#import "DishDetailViewController.h"

#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]
#define buttonLightBlue [UIColor colorWithRed:0 green:.73 blue:.89 alpha:1 ]
#define buttonLightBlueShine [UIColor colorWithRed:.53 green:.91 blue:.99 alpha:1]

#define sortStringArray [NSArray arrayWithObjects:DISTANCE_SORT, RATINGS_SORT, PRICE_SORT, nil]
@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation DishTableViewController

@synthesize tvCell = mTvCell;
@synthesize addItemCell = mAddItemCell;

@synthesize bgImage = mBgImage;
@synthesize theSearchBar = mTheSearchBar;
@synthesize currentLat = mCurrentLat;
@synthesize currentLon = mCurrentLon;
@synthesize currentSearchTerm = mCurrentSearchTerm;
@synthesize searchHeader = mSearchHeader;
@synthesize ratingTextLabel = mRatingTextLabel;
@synthesize priceTextLabel = mPriceTextLabel;
@synthesize distanceTextLabel = mDistanceTextLabel;
@synthesize currentSearchDistance = mCurrentSearchDistance;
@synthesize managedObjectContext = mManagedObjectContext;
@synthesize fetchedResultsController = mFetchedResultsController;

@synthesize conn = mConn;
@synthesize responseData = mResponseData;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        self.title = @"Dishes";
    }
    return self;
}
- (void) setUpSpecificView {
	[self.tableView setTableHeaderView:self.searchHeader];
	self.tableView.delegate = self;
	
	
	[self.theSearchBar setPlaceholder:@"Search Dishes"];
	[self.theSearchBar setShowsCancelButton:YES];
	[self.theSearchBar setDelegate:self];
	[self.theSearchBar setTintColor:kTopDishBlue];
	
	locationController = [[MyCLController alloc] init];
	locationController.delegate = self;
	locationController.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[locationController.locationManager startUpdatingLocation];	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.currentSearchDistance = 200000000;
	
    // Set up the settings button
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
									   initWithImage:[UIImage imageNamed:FILTER_IMAGE_NAME] 
									   style:UIBarButtonItemStylePlain 
									   target:self 
									   action:@selector(showSettings)];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	
	// Set up the map button
	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:GLOBAL_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)];
	
	self.navigationItem.rightBarButtonItem = mapButton;
	
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
	self.title = @"Dishes";
	
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = kTopDishBackground;
	self.tableView.backgroundColor = kTopDishBackground;
	self.navigationController.navigationBar.tintColor = kTopDishBlue;
	[self setUpSpecificView];
	
}

-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	//NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	self.conn = [[NSURLConnection alloc] initWithRequest:request 
												delegate:self 
										startImmediately:TRUE];
}

-(void)initiateNetworkBasedOnSegmentControl{

	NSLog(@"Segmentedcontrol changed, the fetchedResults controller is %@", 
		  self.fetchedResultsController);

	NSString *urlString; 
	
	if (self.currentSearchTerm != nil)
		urlString = [NSString 
					 stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=%d&limit=20&q=%@",
					 NETWORKHOST,self.currentLat,
					 self.currentLon, 
					 self.currentSearchDistance,
					 [self.currentSearchTerm lowercaseString]];
	
	else
		urlString = [NSString 
					 stringWithFormat:@"%@/api/dishSearch?lat=%@&lng=%@&distance=%d&limit=20", 
					 NETWORKHOST, 
					 self.currentLat, 
					 self.currentLon,
					 self.currentSearchDistance];
	
	[self networkQuery:urlString];
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
	//do we need to update the fetch when we come back?
	NSLog(@"the view will appear, lets reload");
	[self updateFetch];
	[super viewWillAppear:animated];
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
#pragma mark network connection stuff

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"didFinishLoading BaseDishTableViewController start");
	NSString *responseText = [[NSString alloc] initWithData:self.responseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	[self processIncomingNetworkText:responseTextStripped];
	self.conn = nil;
	[responseText release];
	NSLog(@"didFinishLoading BaseDishTableViewController end");
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	NSLog(@"connection did fail with error %@", error);
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" 
									   message:@"There was a network issue. Try again later" 
									  delegate:self 
							 cancelButtonTitle:@"Ok" 
							 otherButtonTitles:nil]; 
	[alert show];
	[alert release];
#else	
	//Airplane mode must set _responseText
	[self processIncomingNetworkText:DishSearchResponseText];
#endif
	self.conn = nil;
	self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(self.responseData == nil){
		self.responseData = [[NSMutableData alloc] initWithData:data];
	}
	else{
		if (data) {
			[self.responseData appendData:data];
		}
	}
}

-(void)initiateGrabNewRestaurants:(NSArray *)newRestaurantIds {
	NSMutableString *query = [NSMutableString stringWithFormat:@"%@%@", NETWORKHOST, @"/api/restaurantDetail?"];
	
	for (NSNumber *n in newRestaurantIds) {
		[query appendString:[NSString stringWithFormat:@"id[]=%@&", n]];
	}
	NSLog(@"query is %@", query);
	NSURL *url;
	NSURLRequest *request;
	//NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	self.conn = [[NSURLConnection alloc] initWithRequest:request 
												delegate:self 
										startImmediately:TRUE];
	
}
#pragma mark -
#pragma mark Util
-(void)processIncomingDishesWithJsonArray:(NSArray *)dishesArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	NSMutableArray *newRestaurantsWeNeedToGet = [NSMutableArray array];
	for (NSDictionary *dishDict in dishesArray) {
		//   query the datastore
		NSFetchRequest *dishFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Dish" 
													   inManagedObjectContext:self.managedObjectContext];
		NSPredicate *dishFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
								   [dishDict objectForKey:@"id"]];
		
		[dishFetchRequest setEntity:whichType];
		 
		[dishFetchRequest setPredicate:dishFilter];
		NSError *error;
		NSArray *dishesMatching = [self.managedObjectContext
										 executeFetchRequest:dishFetchRequest error:&error];
		[dishFetchRequest release];
	
		Dish *dish;
		//   if it exists, update
		if ([dishesMatching count] == 1) {
			dish = [dishesMatching objectAtIndex:0];
		}		
		//   else 
		else if ([dishesMatching count] == 0) {
			//       add it
			dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
																	inManagedObjectContext:self.managedObjectContext];
		}
		else {
			NSAssert(TRUE, @"There were %d dishes matching id %d", 
				   [dishesMatching count],
				   [dishDict objectForKey:@"id"]);
		}
		[dish setDish_id:[dishDict objectForKey:@"id"]];
		
		[dish setObjName:[NSString stringWithFormat:@"%@", [dishDict objectForKey:@"name"]]];
		[dish setDish_description:[dishDict objectForKey:@"description"]];
		[dish setLatitude:[dishDict objectForKey:@"latitude"]];
		[dish setLongitude:[dishDict objectForKey:@"longitude"]];
		[dish setNegReviews:[dishDict objectForKey:@"negReviews"]];
		[dish setPhotoURL:[dishDict objectForKey:@"photoURL"]];
		[dish setPosReviews:[dishDict objectForKey:@"posReviews"]];
		
		CLLocation *l = [[CLLocation alloc] initWithLatitude:[[dish latitude] floatValue] longitude:[[dish longitude] floatValue]];
		CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
		float distanceInMiles = dist/1609.344; 
		[dish setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
		NSLog(@"the dish we just created %@", dish);
		
		NSArray *tagsArray = [dishDict objectForKey:@"tags"];
		for (NSDictionary *tag in tagsArray){
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kMealTypeString] )
				[dish setMealType:[tag objectForKey:@"id"]];
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kPriceTypeString] )						
				[dish setPrice:[tag objectForKey:@"id"]];			
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kLifestyleTypeString] )						
				[dish setLifestyleType:[tag objectForKey:@"id"]];			
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kCuisineTypeString] )						
				[dish setCuisineType:[tag objectForKey:@"id"]];
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kAllergenTypeString] )						
				[dish setAllergenType:[tag objectForKey:@"id"]];
			
		}	
		
		//query it's restaurant
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		whichType = [NSEntityDescription entityForName:@"Restaurant" 
								inManagedObjectContext:self.managedObjectContext];
		NSPredicate *restaurantFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
								   [dishDict objectForKey:@"restaurantID"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restaurantFilter];
		NSArray *restosMatching = [self.managedObjectContext
								   executeFetchRequest:restoFetchRequest error:&error];
		[restoFetchRequest release];
		
		Restaurant *restaurant;
		//   if it exists, update
		if ([restosMatching count] == 1) {
			restaurant = [restosMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restosMatching count] == 0) {
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
														 inManagedObjectContext:self.managedObjectContext];	
			[newRestaurantsWeNeedToGet addObject:[dishDict objectForKey:@"restaurantID"]];
		}
		else {
			NSAssert(TRUE, @"There were %d restaurants matching id %d", 
					 [restosMatching count],
					 [dishDict objectForKey:@"restaurantID"]);
		}
		NSLog(@"this is the restaurant for this dish %@", 
			  [dishDict objectForKey:@"restaurantName"]);
		[restaurant setRestaurant_id:[dishDict objectForKey:@"restaurantID"]];
		[restaurant setObjName:[NSString stringWithFormat:@"%@", [dishDict objectForKey:@"restaurantName"]]];
		[dish setRestaurant:restaurant];
		NSLog(@"restaurant we just created is %@", restaurant);
	}
	NSError *error;
	if(![self.managedObjectContext save:&error]){
		NSLog(@"there was a core data error when saving");
		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	
	NSLog(@"we need to get these restaurants %@", newRestaurantsWeNeedToGet);
	if ([newRestaurantsWeNeedToGet count] > 0) {
		
		[self initiateGrabNewRestaurants:newRestaurantsWeNeedToGet];
	}
	[self updateFetch];

}

-(void)processIncomingRestaurantsWithJsonArray:(NSArray *)restoArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	for (NSDictionary *restoDict in restoArray) {
		NSLog(@"we've got a restaurant array, lets make objects %@", restoDict);
		//   query the datastore
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Restaurant" 
													 inManagedObjectContext:self.managedObjectContext];
		NSPredicate *restoFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
								   [restoDict objectForKey:@"id"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restoFilter];
		NSError *error;
		NSArray *restoMatching = [self.managedObjectContext
								   executeFetchRequest:restoFetchRequest error:&error];
		[restoFetchRequest release];
		
		Restaurant *restaurant;
		//   if it exists, update
		if ([restoMatching count] == 1) {
			restaurant = [restoMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restoMatching count] == 0) {
			//       add it
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
														 inManagedObjectContext:self.managedObjectContext];
		}
		else {
			NSAssert(TRUE, @"There were %d restaurants matching id %d", 
					 [restoMatching count],
					 [restoDict objectForKey:@"id"]);
		}
		//Do all of the restaurant data setting
		
		NSLog(@"setting the restaurant id %@", restoDict);
		[restaurant setRestaurant_id:[restoDict objectForKey:@"id"]];
		[restaurant setObjName:[NSString stringWithFormat:@"%@", [restoDict objectForKey:@"name"]]];
		[restaurant setLatitude:[restoDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[restoDict objectForKey:@"longitude"]];
		[restaurant setPhone:[restoDict objectForKey:@"phone"]];
		[restaurant setPhotoURL:[restoDict objectForKey:@"photoURL"]];
		[restaurant setAddressLine1:[restoDict objectForKey:@"addressLine1"]];
		[restaurant setAddressLine2:[restoDict objectForKey:@"addressLine2"]];
		[restaurant setCity:[restoDict objectForKey:@"city"]];
		[restaurant setState:[restoDict objectForKey:@"state"]];
		
		for (NSDictionary *restoDishesDict in [restoDict objectForKey:@"dishes"]) {
			//query it's Dishes
			NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
			whichType = [NSEntityDescription entityForName:@"Dish" 
									inManagedObjectContext:self.managedObjectContext];
			NSPredicate *restosDishesFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
											 [restoDishesDict objectForKey:@"id"]];
			
			[restoFetchRequest setEntity:whichType];
			
			[restoFetchRequest setPredicate:restosDishesFilter];
			NSArray *restosDishesMatching = [self.managedObjectContext
									   executeFetchRequest:restoFetchRequest error:&error];
			[restoFetchRequest release];
			
			Dish *dish;
			//   if it exists, update
			if ([restosDishesMatching count] == 1) {
				dish = [restosDishesMatching objectAtIndex:0];
			}		
			//   else 
			else if ([restosDishesMatching count] == 0) {
				dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
																		 inManagedObjectContext:self.managedObjectContext];		
			}
			else {
				NSAssert(TRUE, @"There were %d dishes matching id %d", 
						 [restosDishesMatching count],
						 [restoDishesDict objectForKey:@"id"]);
			}
			NSLog(@"the dish here is %@", restoDishesDict);
			[dish setDish_description:[restoDishesDict objectForKey:@"description"]];
			[dish setDish_id:[restoDishesDict objectForKey:@"id"]];
			[dish setLatitude:[restoDishesDict objectForKey:@"latitude"]];
			[dish setLongitude:[restoDishesDict objectForKey:@"longitude"]];
			[dish setObjName:[NSString stringWithFormat:@"%@", [restoDishesDict objectForKey:@"name"]]];
			[dish setNegReviews:[restoDishesDict objectForKey:@"negReviews"]];
			[dish setPhotoURL:[restoDishesDict objectForKey:@"photoURL"]];
			[dish setPosReviews:[restoDishesDict objectForKey:@"posReviews"]];
			[dish setRestaurant:restaurant];
		}
	}
	NSError *error;
	if(![self.managedObjectContext save:&error]){
		NSLog(@"there was a core data error when saving");
		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	//[self.tableView reloadData];
}


-(void)processIncomingNetworkText:(NSString *)responseText{
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;

	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		NSLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		return;
	}
	
	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"jsoning error %@", error);
		NSLog(@"the offensive json %@", responseText);
	}
	
	NSArray *responseAsArray = [responseAsDictionary objectForKey:@"dishes"];
	[self processIncomingDishesWithJsonArray:[responseAsDictionary objectForKey:@"dishes"]];
	[self processIncomingRestaurantsWithJsonArray:[responseAsDictionary objectForKey:@"restaurants"]];
	[parser release];
	NSLog(@"responseAsArray from DishTableViewController = %@", responseAsArray);

	//TODO fix this. it should not be looking for specific keys. Salil's new api is probably going to fix all of this
	if(![self.managedObjectContext save:&error]){
		NSLog(@"there was a core data error when saving");
		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	
	[self updateFetch];
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
	AppModel *app = [AppModel instance];
	
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
	if ([[[AppModel instance] selectedPrice] intValue] != 0) {
		
		NSLog(@"the else predicate %@ == %d", 
			  @"price", [[AppModel instance] selectedPrice]);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"price", [app selectedPriceId]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on mealType
	if ([[[AppModel instance] selectedMeal] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"mealType", [app selectedMealId]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on cuisine
	if ([[[AppModel instance] selectedCuisineId] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"cuisineType", [app selectedCuisineId]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on allergen
	if ([[[AppModel instance] selectedAllergenId] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"allergenType", [app selectedAllergenId]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on lifestyle
	if ([[[AppModel instance] selectedLifestyleId] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"lifestyleType", [app selectedLifestyleId]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	if ([self respondsToSelector:@selector(restaurantDetailFilter)]) {
		[filterPredicateArray addObject:[self restaurantDetailFilter]];
	}
}
-(void) updateFetch {
	
	/*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    // Edit the entity name as appropriate.

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" 
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
								ascending:TRUE];
	
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

	selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[self pushDishViewController:selectedObject];
	//else {
//		selectedObject = [[self.rltv fetchedResultsController] objectAtIndexPath:indexPath];
//		[self pushRestaurantViewController:selectedObject];
//	}
	//[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void) pushDishViewController:(ObjectWithImage *) selectedObject{
	NSLog(@"DishName from DishTableViewController %@", [selectedObject objName]);
	
	DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithNibName:@"DishDetailViewController" bundle:nil];
	[detailViewController setThisDish:(Dish*)selectedObject];
	
	//[detailViewController setDish:(Dish*)selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[selectedObject objName]];
	[detailViewController release];
	
}


#pragma mark -
#pragma mark table view
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	return [sectionInfo numberOfObjects];
}


-(UITableViewCell *)tableView:(UITableView *)tableView dishCellAtIndexPath:(NSIndexPath *)indexPath {
	//Return the Descriptor cell for adding a new dish
	if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:[indexPath section]] numberOfObjects])
		return self.addItemCell;
	
    static NSString *CellIdentifier = @"DishCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"DishTableViewCell" owner:self options:nil];
		cell = self.tvCell;
	}
	
	//Query the results controller
	Dish *thisDish = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	//Build the UIElements
    UILabel *dishName;
	dishName = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DISH_NAME_TAG];
	dishName.text = thisDish.objName;
	
	UILabel *resto;
	resto = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_RESTAURANT_NAME_TAG];
	resto.text = @"Resto Name";
	resto.text = [[thisDish restaurant] objName];
	
	UILabel *mealType;
	mealType = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_MEALTYPE_TAG];
	mealType.text = @"$$$";
	
	//TODO Ok this is a fail, I need to loop through tags
	//to find the price and mealtype
	for (NSDictionary *d in [[AppModel instance] mealTypeTags]) {		
		if ([[d objectForKey:@"id"] intValue]== [[thisDish mealType] intValue]) {
			mealType.text = [NSString stringWithFormat:@"%@", [d objectForKey:@"name"]];
			continue;
		}
	}
	
	UILabel *distance;
	distance = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DIST_TAG];
	
	CLLocation *l = [[CLLocation alloc] initWithLatitude:[[thisDish latitude] floatValue] 
											   longitude:[[thisDish longitude] floatValue]];
	CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
	
	//convert from meters to miles
	float distanceInMiles = dist/1609.344; 
	
	distance.text = [NSString stringWithFormat:@"%.1f mi", distanceInMiles];	
	//[thisDish setDistance:[NSNumber numberWithFloat:distanceInMiles]];
	
	UILabel *percentage = (UILabel *)[cell viewWithTag:PERCENTAGE_TAG];
	percentage.text = [NSString stringWithFormat:@"%@%@", [thisDish calculated_rating], @"%"]; 
	
	UILabel *upVotes;
	upVotes = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_UPVOTES_TAG];
	upVotes.text = [NSString stringWithFormat:@"+%@", 
					[thisDish posReviews]];
	
	UILabel *downVotes;
	downVotes = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DOWNVOTES_TAG];
	downVotes.text = [NSString stringWithFormat:@"-%@", 
					  [thisDish negReviews]];
	
	UILabel *priceNumber;
	priceNumber = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_COST_TAG];
	
	//TODO Ok this is a fail, I need to loop through tags
	//to find the price and mealtype
	for (NSDictionary *d in [[AppModel instance] priceTags]) {
		if ([[d objectForKey:@"id"] intValue]== [[thisDish price] intValue]) {
			priceNumber.text = 	[d objectForKey:@"name"];
			continue;
		}
	}
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:DISHTABLEVIEW_IMAGE_TAG];
	
	AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:[imageView frame]] autorelease];
	asyncImage.tag = 999;
	if ([thisDish imageData]) {
		NSLog(@"we've got this image, no need to load it");
		//set the image with what we've got
		imageView.image = [UIImage imageWithData:[thisDish imageData]];
	}
	else{
		//NSLog(@"don't have this image, loading it %@", [thisDish photoURL]);
		if( [[thisDish photoURL] length] > 0 ){
			NSRange aRange = [[thisDish photoURL] rangeOfString:@"http://"];
			NSString *prefix = @"";
			if (aRange.location ==NSNotFound)
				prefix = NETWORKHOST;
			//TODO we are not getting height and width
			//NSString *urlString = [NSString stringWithFormat:@"%@%@&w=%d&h=%d", 
			
			NSString *urlString = [NSString stringWithFormat:@"%@%@", 
								   prefix, 
								   [thisDish photoURL], 
								   DISHDETAILIMAGECELLHEIGHT, 
								   DISHDETAILIMAGECELLHEIGHT];
			
			NSURL *photoUrl = [NSURL URLWithString:urlString];
			[asyncImage setOwningObject:thisDish];
			[asyncImage loadImageFromURL:photoUrl 
						   withImageView:imageView 
								 isThumb:YES 
				   showActivityIndicator:NO];
			[cell.contentView addSubview:asyncImage];
		}
	}
    // Configure the cell.
	// [self configureCell:cell atIndexPath:indexPath];
	//    }
	[cell setOpaque:FALSE];
	
    return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self tableView:tableView dishCellAtIndexPath:indexPath];
	
}

#pragma mark -

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
	[[AppModel instance] setCurrentLocation:location];
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
			//I'm taking this out. It was an empty function call anyway
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
		
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

- (void)dealloc {

	self.addItemCell = nil;
	self.tvCell = nil;
	
	self.currentSearchTerm = nil;
	
	//TODO can probably get rid of this in favor of the appmodel's current latlon
	self.currentLat = nil;
	self.currentLon = nil;
	
	self.bgImage = nil;
	
	self.theSearchBar = nil;
	self.searchHeader = nil;
	
	self.ratingTextLabel = nil;
	self.priceTextLabel = nil;
	self.distanceTextLabel = nil;
	
	self.managedObjectContext = nil;
	self.fetchedResultsController = nil;
	
	self.conn = nil;
	self.responseData = nil;

	[super dealloc];

}


@end

