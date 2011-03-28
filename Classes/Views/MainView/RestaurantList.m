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
#import "AppModel.h"
#import "Dish.h"
#import "asyncimageview.h"
#import "NearbyMapViewController.h"
#import "JSON.h"

@implementation RestaurantList

@synthesize fetchedResultsController = mFetchedResultsController;
@synthesize managedObjectContext = mManagedObjectContext;
@synthesize tvCell = mTvCell;
@synthesize tableHeaderView = mTableHeaderView;
@synthesize searchBar = mSearchBar;
@synthesize currentSearchTerm = mCurrentSearchTerm;
@synthesize currentSearchDistance = mCurrentSearchDistance;
@synthesize responseData = mResponseData;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    if (self = [super initWithNibName:nibName bundle:nibBundle]) {
        self.title = @"Restaurants";
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:GLOBAL_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)];
	self.navigationItem.rightBarButtonItem = mapButton;

	self.navigationController.navigationBar.tintColor = kTopDishBlue;
	DLog(@"tableview %@", self.tableView);
	[self.tableView setTableHeaderView:self.tableHeaderView];
	
	[self.searchBar setPlaceholder:@"Search Restaurants"];
	[self.searchBar setShowsCancelButton:YES];
	[self.searchBar setDelegate:self];
	[self.searchBar setTintColor:kTopDishBlue];
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
	return [sectionInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;
	//return 45;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RestaurantTableViewCell";
    
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	//DLog(@"this restaurant is %@", thisRestaurant);
	
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
	
	UILabel *distanceLabel;
	distanceLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_DISTANCE_TAG];
	NSSet *dishes = [thisRestaurant restaurant_dish];
	Dish *aDish = (Dish *)[dishes anyObject];
	
	distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", [[aDish distance] floatValue]];	
	
	UILabel *positiveReviewsLabel;
	positiveReviewsLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_POSREVIEWS_TAG];
	positiveReviewsLabel.text = @"0";
	
	UILabel *negativeReviewsLabel;
	negativeReviewsLabel = (UILabel *)[cell viewWithTag:RESTAURANT_TABLEVIEW_NEGREVIEWS_TAG];
	negativeReviewsLabel.text = @"0";	
	
	UIImageView *restaurantImageView;
	restaurantImageView = (UIImageView *)[cell viewWithTag:RESTAURANT_TABLEVIEW_IMAGE_TAG];

	AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:[restaurantImageView frame]] autorelease];
	asyncImage.tag = 999;
	if ([thisRestaurant imageData]) {
		DLog(@"we've got this image, no need to load it");
		//set the image with what we've got
		restaurantImageView.image = [UIImage imageWithData:[thisRestaurant imageData]];
	}
	else{
		if( [[thisRestaurant photoURL] length] > 0 ){
			NSRange aRange = [[thisRestaurant photoURL] rangeOfString:@"http://"];
			NSString *prefix = @"";
			if (aRange.location ==NSNotFound)
				prefix = NETWORKHOST;
			
			NSString *urlString = [NSString stringWithFormat:@"%@%@=s%d", 
								   prefix, 
								   [thisRestaurant photoURL], 
								   OBJECTDETAILIMAGECELLHEIGHT, 
								   OBJECTDETAILIMAGECELLHEIGHT];
			
			NSURL *photoUrl = [NSURL URLWithString:urlString];
			[asyncImage setOwningObject:thisRestaurant];
			[asyncImage loadImageFromURL:photoUrl 
						   withImageView:restaurantImageView 
								 isThumb:YES 
				   showActivityIndicator:NO];
			[cell.contentView addSubview:asyncImage];
		}
	}
	
	
	
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
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return mFetchedResultsController;
}  

#pragma mark -
#pragma mark  the fetch and filters

-(void) populatePredicateArray:(NSMutableArray *)filterPredicateArray{
	NSPredicate *filterPredicate;
	
	//Filter based on search
	if (self.currentSearchTerm && [self.currentSearchTerm length] > 0) {
		
		NSString *attributeName = @"objName";
		NSString *attributeValue = self.currentSearchTerm;
		DLog(@"the predicate we are sending: %@ contains(cd) %@ AND %@ == %d",
			 attributeName, attributeValue,
			 @"price", [[AppModel instance] selectedPrice]);
		
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",
						   attributeName, attributeValue];
		
		DLog(@"the real predicate is %@", filterPredicate);
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on price
	//if ([[[AppModel instance] selectedPrice] intValue] != 0) {
//		
//		DLog(@"the else predicate %@ == %d", 
//			 @"price", [[AppModel instance] selectedPrice]);
//		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
//						   @"price", [app selectedPrice]];
//		
//		[filterPredicateArray addObject:filterPredicate];
//	}
//	
//	//Filter based on mealType
//	if ([[[AppModel instance] selectedMeal] intValue] != 0) {
//		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
//						   @"mealType", [app selectedMeal]];
//		
//		[filterPredicateArray addObject:filterPredicate];
//	}
//	
//	//Filter based on cuisine
//	if ([[[AppModel instance] selectedCuisine] intValue] != 0) {
//		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
//						   @"cuisineType", [app selectedCuisine]];
//		
//		[filterPredicateArray addObject:filterPredicate];
//	}
//	
//	//Filter based on allergen
//	if ([[[AppModel instance] selectedAllergen] intValue] != 0) {
//		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
//						   @"allergenType", [app selectedAllergen]];
//		
//		[filterPredicateArray addObject:filterPredicate];
//	}
//	
//	//Filter based on lifestyle
//	if ([[[AppModel instance] selectedLifestyle] intValue] != 0) {
//		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
//						   @"lifestyleType", [app selectedLifestyle]];
//		
//		[filterPredicateArray addObject:filterPredicate];
//	}
	
}


-(void) updateFetch {
	DLog(@"updating the restaurant fetch");
	/*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    // Edit the entity name as appropriate.
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Restaurant" 
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
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:@"distance" 
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
    //[sortDescriptor release];
    //[currentSearchTerm release];
	//self.currentSearchTerm = nil;
    NSError *error = nil;
    if (![mFetchedResultsController performFetch:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	//Finally, reload the data with the latest fetch
	[self.tableView reloadData];
	
}

-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	//NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	DLog(@"url from restaurantlist is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	[[NSURLConnection connectionWithRequest:request delegate:self] start];
}

-(void)initiateNetworkBasedOnSegmentControl{
	
	DLog(@"Segmentedcontrol changed, the fetchedResults controller is %@", 
		 self.fetchedResultsController);
	
	NSString *urlString; 
	CLLocation *l = [[AppModel instance] currentLocation];
	
	if (self.currentSearchTerm == nil) {
		self.currentSearchTerm = @"";
	}
	urlString = [NSString 
				 stringWithFormat:@"%@/api/restaurantSearch?lat=%f&lng=%f&distance=%d&limit=20&q=%@",
				 NETWORKHOST,
				 l.coordinate.latitude,
				 l.coordinate.longitude, 
				 self.currentSearchDistance,
				 [self.currentSearchTerm lowercaseString]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[self networkQuery:urlString];
}

#pragma mark -
#pragma mark Network data processing
#pragma mark This should be put into an NSOperationQueue

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
			NSString *errorString = [NSString stringWithFormat:@"There were %d dishes matching id %d", 
									 [dishesMatching count],
									 [dishDict objectForKey:@"id"]];
			NSAssert(TRUE, errorString);
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
		[l release];
		float distanceInMiles = dist/1609.344; 
		[dish setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
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
			NSString *s = [NSString stringWithFormat:@"There were %d restaurants matching id %d", 
						   [restosMatching count],
						   [dishDict objectForKey:@"restaurantID"]];
			NSAssert(TRUE, s);
		}
		
		[restaurant setRestaurant_id:[dishDict objectForKey:@"restaurantID"]];
		[restaurant setObjName:[NSString stringWithFormat:@"%@", [dishDict objectForKey:@"restaurantName"]]];
		
		//Should be no extra work setting lat/long and distance
		[restaurant setLatitude:[dishDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[dishDict objectForKey:@"longitude"]];
		[restaurant setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
		[dish setRestaurant:restaurant];
	}
	NSError *error;
	DLog(@"saving the incoming dishes");
	
	if(![self.managedObjectContext save:&error]){
		DLog(@"there was a core data error when saving incoming dishes");
		DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	
	//For all of the new restaurants we just created, go fetch their data
	if ([newRestaurantsWeNeedToGet count] > 0) {
		
		[self initiateGrabNewRestaurants:newRestaurantsWeNeedToGet];
	}
	[self updateFetch];
	
}

-(void)processIncomingRestaurantsWithJsonArray:(NSArray *)restoArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	DLog(@"got a bunch of new restaurants from DishTableViewController, creating those");
	for (NSDictionary *restoDict in restoArray) {
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
			NSString *s = [NSString stringWithFormat:@"There were %d restaurants matching id %d", 
						   [restoMatching count],
						   [restoDict objectForKey:@"id"]];
			NSAssert(TRUE, s);
		}
		//Do all of the restaurant data setting
		
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
				NSString *s = [NSString stringWithFormat: @"There were %d dishes matching id %d", 
							   [restosDishesMatching count],
							   [restoDishesDict objectForKey:@"id"]];
				NSAssert(TRUE, s);
			}
			[dish setDish_description:[restoDishesDict objectForKey:@"description"]];
			[dish setDish_id:[restoDishesDict objectForKey:@"id"]];
			[dish setPrice:[restoDishesDict objectForKey:@"price"]];
			
			NSNumber *price = [AppModel extractTag:@"Price" fromArrayOfTags:[restoDishesDict objectForKey:@"tags"]];
			//DLog(@"price is %@", price);
			[dish setPrice:price];
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
	DLog(@"saving the incoming restaurants");
	if(![self.managedObjectContext save:&error]){
		DLog(@"there was a core data error when saving incoming restaurants");
		DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
}

-(void)processIncomingNetworkText:(NSString *)responseText{
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[parser release];
		return;
	}
	
	if(error != nil){
		DLog(@"there was an error when jsoning");
		DLog(@"jsoning error %@", error);
		DLog(@"the offensive json %@", responseText);
	}
	
	DLog(@"we've got new dishes and or restaurants %@", responseAsDictionary);
	
	[self processIncomingDishesWithJsonArray:[responseAsDictionary objectForKey:@"dishes"]];
	[self processIncomingRestaurantsWithJsonArray:[responseAsDictionary objectForKey:@"restaurants"]];
	[parser release];
	
	[self updateFetch];
	self.responseData = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark network connection stuff

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSString *responseText = [[NSString alloc] initWithData:self.responseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	[self processIncomingNetworkText:responseTextStripped];
	[responseText release];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	DLog(@"connection did fail with error %@", error);
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
	DLog(@"the search bar text changed %@", searchText);
	
	//Send the network request
	self.currentSearchTerm = searchText;
	[self initiateNetworkBasedOnSegmentControl];
	
	//Limit the core data output
	[self updateFetch];
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
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
	self.tvCell = nil;
	self.tableHeaderView;
	self.currentSearchTerm = nil;
    [super dealloc];
}


@end
