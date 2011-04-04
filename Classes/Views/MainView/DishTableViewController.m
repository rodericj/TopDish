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
#import "SettingsView1.h"
#import "AppModel.h"
#import "asyncimageview.h"
#import "DishDetailViewController.h"
#import "JSON.h"

#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]
#define buttonLightBlue [UIColor colorWithRed:0 green:.73 blue:.89 alpha:1 ]
#define buttonLightBlueShine [UIColor colorWithRed:.53 green:.91 blue:.99 alpha:1]

#define kSearchCountLimit 10
#define kMinimumDishesToShow 10
#define kMaxDistance kOneMileInMeters * 25

#define sortStringArray [NSArray arrayWithObjects:@"nothing", DISTANCE_SORT, RATINGS_SORT, PRICE_SORT, nil]
@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation DishTableViewController

@synthesize tvCell = mTvCell;
@synthesize addItemCell = mAddItemCell;

@synthesize bgImage = mBgImage;
@synthesize theSearchBar = mTheSearchBar;
@synthesize currentSearchTerm = mCurrentSearchTerm;
@synthesize searchHeader = mSearchHeader;
@synthesize ratingTextLabel = mRatingTextLabel;
@synthesize priceTextLabel = mPriceTextLabel;
@synthesize distanceTextLabel = mDistanceTextLabel;
@synthesize currentSearchDistance = mCurrentSearchDistance;
@synthesize managedObjectContext = mManagedObjectContext;
@synthesize fetchedResultsController = mFetchedResultsController;

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
	self.currentSearchDistance = kOneMileInMeters;
	
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
	DLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request 
												delegate:self 
										startImmediately:TRUE];
	if (!mConnectionLookup) {
		mConnectionLookup = [[NSMutableDictionary dictionary] retain];
	}
	[mConnectionLookup setObject:[NSMutableData data] forKey:[conn description]];
	[conn release];
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
				 stringWithFormat:@"%@/api/dishSearch?lat=%f&lng=%f&distance=%d&limit=%d&q=%@",
				 NETWORKHOST,
				 l.coordinate.latitude,
				 l.coordinate.longitude, 
				 self.currentSearchDistance,
				 kSearchCountLimit,
				 [self.currentSearchTerm lowercaseString]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	
	[self networkQuery:urlString];
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
	//do we need to update the fetch when we come back?
	[self updateFetch];
	[super viewWillAppear:animated];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//DLog(@"here we are using the managed Object %@", managedObject);
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
	DLog(@"request complete ---------------------");
	NSData *thisResponseData = [mConnectionLookup objectForKey:[theConnection description]];

	
	NSString *responseText = [[NSString alloc] initWithData:thisResponseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	//Send this incoming content to the IncomingProcessor Object
	IncomingProcessor *proc = [[IncomingProcessor alloc] initWithProcessorDelegate:self];
	DLog(@"PROCESSOR the processor is set up. Register for notifications");
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(buildRestaurantNetworkGrab:) 
												 name:NSNotificationStringDoneProcessingDishes 
											   object:nil];
	
	[[[AppModel instance] queue] addOperation:[proc taskWithData:responseTextStripped]];
	DLog(@"PROCESSOR  proc task is set up");
	[proc release];
	DLog(@"PROCESSOR the proc is released");
	DLog(@"out of incoming processor");
	
	//Hate to do this, but I need to parse the JSON to figure out how many results we got back
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	DLog(@"we got %d dishes.", [[responseAsDictionary objectForKey:@"dishes"] count]);
	
		if ([[responseAsDictionary objectForKey:@"dishes"] count] < kMinimumDishesToShow && self.currentSearchDistance < kMaxDistance) {
			DLog(@"Need to resend with a larger radius: %d -> %d. UnRegister for notifications",
				 [[responseAsDictionary objectForKey:@"dishes"] count], 
				 self.currentSearchDistance, 
				 self.currentSearchDistance*5);
			
			self.currentSearchDistance *= 5;
			
			//Need to remove self from the observer list so we don't get redundant notifications
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			[self initiateNetworkBasedOnSegmentControl];
		}
	
	[parser release];
	
	[responseText release];
	
}
-(void)saveComplete {
	DLog(@"the save is complete");
	[self updateFetch];
}

-(void)buildRestaurantNetworkGrab:(NSNotification *)notification {
	DLog(@"begin the network request to get the restaurants");
	DLog(@"the notification is %@", [notification userInfo]);
	
	//remove myself
	DLog(@"UnRegister for notifications in buildRestaurantNetworkGrab");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if ([[[notification userInfo] objectForKey:@"restaurantIds"] count]) {
		
		NSMutableString *query = [NSMutableString stringWithFormat:@"%@%@", NETWORKHOST, @"/api/restaurantDetail?"];
		
		for (NSNumber *n in [[notification userInfo] objectForKey:@"restaurantIds"]) {
			[query appendString:[NSString stringWithFormat:@"id[]=%@&", n]];
		}
		[self performSelectorOnMainThread:@selector(networkQuery:) 
							   withObject:query
							waitUntilDone:NO];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[mConnectionLookup removeObjectForKey:[connection description]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSMutableData *thisResponseData = [mConnectionLookup objectForKey:[connection description]];
	if (data)
		[thisResponseData appendData:data];
}


-(NSArray *)getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString *)key{
	NSEnumerator *enumerator = [responseAsArray objectEnumerator];
	id anObject;
	NSMutableArray *ret = [NSMutableArray array];
	while (anObject = (NSDictionary *)[enumerator nextObject]){
		[ret addObject:[anObject objectForKey:key]];
	}
	//DLog(@"At the end of all that, the return is %@", ret);
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
		DLog(@"the predicate we are sending: %@ contains(cd) %@ AND %@ == %d",
			  attributeName, attributeValue,
			  @"price", [[AppModel instance] selectedPrice]);
		
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",
						   attributeName, attributeValue];
		
		DLog(@"the real predicate is %@", filterPredicate);
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on price
	if ([[[AppModel instance] selectedPrice] intValue] != 0) {
		
		DLog(@"the else predicate %@ == %d", 
			  @"price", [[AppModel instance] selectedPrice]);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"price", [app selectedPrice]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on mealType
	if ([[[AppModel instance] selectedMeal] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"mealType", [app selectedMeal]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on cuisine
	if ([[[AppModel instance] selectedCuisine] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"cuisineType", [app selectedCuisine]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on allergen
	if ([[[AppModel instance] selectedAllergen] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"allergenType", [app selectedAllergen]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on lifestyle
	if ([[[AppModel instance] selectedLifestyle] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"lifestyleType", [app selectedLifestyle]];
		
		[filterPredicateArray addObject:filterPredicate];
	}

}
-(void) updateFetch {
	DLog(@"updating the fetch");
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
	
	if ([self respondsToSelector:@selector(restaurantDetailFilter)])
		[filterPredicateArray addObject:[self restaurantDetailFilter]];
	
	NSPredicate *fullPredicate = [NSCompoundPredicate 
								  andPredicateWithSubpredicates:filterPredicateArray]; 

	[fetchRequest setPredicate:fullPredicate];

	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
    
	//Create array with sort params, then store in NSUserDefaults
	BOOL ascending = TRUE;
	int sorterValue = [[AppModel instance] sorter];
	if (sorterValue < 0) {
		ascending = FALSE;
		sorterValue = -sorterValue;
	}
	
	NSString *sorter = [sortStringArray objectAtIndex:sorterValue];
	DLog(@"sorter is %@", sorter);
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:sorter 
								ascending:ascending];
	
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
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	
	//Finally, reload the data with the latest fetch
	[self.tableView reloadData];

}
 
#pragma mark -
#pragma mark Table view data delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"adding this didSelect");
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
	DLog(@"DishName from DishTableViewController %@", [selectedObject objName]);
	
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
	
	AppModel *app = [AppModel instance];
	
	UILabel *mealType;
	mealType = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_MEALTYPE_TAG];
	mealType.text = [app selectedMealName];
	
	if ([thisDish mealType])
		mealType.text = [app tagNameForTagId:[thisDish mealType]];
	else {
		DLog(@"is something wrong with this dish's mealType %@", [thisDish mealType]);
		NSString *n = [NSString stringWithFormat:@"This dish has a bad mealtype %@", [thisDish dish_id]];
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Data Error" 
															message:n 
														   delegate:self 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		
		NSAssert(NO, @"this dish has an invalid meal tag");
	}
	
	UILabel *distance;
	distance = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DIST_TAG];
	
	CLLocation *l = [[CLLocation alloc] initWithLatitude:[[thisDish latitude] floatValue] 
											   longitude:[[thisDish longitude] floatValue]];
	CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
	[l release];
	
	if (dist != -1) {
		//convert from meters to miles
		float distanceInMiles = dist/kOneMileInMeters; 
		NSAssert(distanceInMiles > 0, @"the distance is not > 0");
		distance.text = [NSString stringWithFormat:@"%2.2f", distanceInMiles];	
	}
	else
		//Let's just set the text to blank until the current location is determined, at which 
		//point, we'll update the fetch, which will update the cell
		distance.text = @"";
	
	UILabel *upVotes;
	upVotes = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_UPVOTES_TAG];
	upVotes.text = [NSString stringWithFormat:@"+%@", 
					[thisDish posReviews]];
	
	UILabel *downVotes;
	downVotes = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DOWNVOTES_TAG];
	downVotes.text = [NSString stringWithFormat:@"-%@", 
					  [thisDish negReviews]];
	
	if ([thisDish posReviews] > [thisDish negReviews]){
		upVotes.font =[UIFont boldSystemFontOfSize:28.0];
		downVotes.font =[UIFont boldSystemFontOfSize:20.0];
	}else if([thisDish posReviews] < [thisDish negReviews]){
		upVotes.font =[UIFont boldSystemFontOfSize:20.0];
		downVotes.font =[UIFont boldSystemFontOfSize:28.0];
	}else{
		upVotes.font =[UIFont boldSystemFontOfSize:24.0];
		downVotes.font =[UIFont boldSystemFontOfSize:24.0];
	}
	
	UILabel *priceNumber;
	priceNumber = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_COST_TAG];

	if ([thisDish price])
		priceNumber.text = [app tagNameForTagId:[thisDish price]];
	else {
		DLog(@"is something wrong with this dish's (%@) price (%@) ", [thisDish objName], [thisDish objName]);
	}


	UIImageView *imageView = (UIImageView *)[cell viewWithTag:DISHTABLEVIEW_IMAGE_TAG];
	
	AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:[imageView frame]] autorelease];
	asyncImage.tag = 999;
	if ([thisDish imageData]) {
		DLog(@"we've got this image, no need to load it");
		//set the image with what we've got
		imageView.image = [UIImage imageWithData:[thisDish imageData]];
	}
	else{
		//DLog(@"don't have this image, loading it %@", [thisDish photoURL]);
		if( [[thisDish photoURL] length] > 0 ){
			NSRange aRange = [[thisDish photoURL] rangeOfString:@"http://"];
			NSString *prefix = @"";
			if (aRange.location == NSNotFound)
				prefix = NETWORKHOST;
						
			NSString *urlString = [NSString stringWithFormat:@"%@%@=s%d", 
								   prefix, 
								   [thisDish photoURL], 
								   OBJECTDETAILIMAGECELLHEIGHT, 
								   OBJECTDETAILIMAGECELLHEIGHT];
			
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
	DLog(@"sort by distance");
	
	if ([[AppModel instance] sorter] == kSortByDistance)
		[[AppModel instance] setSorter:-kSortByDistance];
	else {
		[[AppModel instance] setSorter:kSortByDistance];
	}
	
	[self updateFetch];
}
-(IBAction) sortByRating
{
	DLog(@"sort by Rating %d", [[AppModel instance] sorter]);
	if ([[AppModel instance] sorter] == -kSortByRating)
		[[AppModel instance] setSorter:kSortByRating];
	else {
		[[AppModel instance] setSorter:-kSortByRating];
	}

	[self updateFetch];
}
-(IBAction) sortByPrice
{
	DLog(@"sort by Price");
	
	if ([[AppModel instance] sorter] == kSortByPrice)
		[[AppModel instance] setSorter:-kSortByPrice];
	else {
		[[AppModel instance] setSorter:kSortByPrice];
	}
	
	[self updateFetch];
}

#pragma mark -
#pragma mark Location
- (void)locationError:(NSError *)error {
	DLog(@"Error getting location %@", error);
}
	
- (void)locationUpdate:(CLLocation *)location {
	[[AppModel instance] setCurrentLocation:location];
	[self getNearbyItems:location];
	if (!locationController) {
		locationController = [[MyCLController alloc] init];
	}
	locationController.delegate = self;
	[locationController.locationManager stopUpdatingLocation];
}

- (void)getNearbyItems:(CLLocation *)location {
	DLog(@"getNearbyItems Called %@. Accuracy: %d, %d", [location description], location.verticalAccuracy, location.horizontalAccuracy);
	
	//NSAssert(location != NULL, @"the location was null which means that the thread is doing something intersting. Lets send this back.");
	[self initiateNetworkBasedOnSegmentControl];
	
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

- (void)dealloc {

	self.addItemCell = nil;
	self.tvCell = nil;
	
	self.currentSearchTerm = nil;
	
	self.bgImage = nil;
	
	self.theSearchBar = nil;
	self.searchHeader = nil;
	
	self.ratingTextLabel = nil;
	self.priceTextLabel = nil;
	self.distanceTextLabel = nil;
	
	self.managedObjectContext = nil;
	self.fetchedResultsController = nil;
	
	[mConnectionLookup release];
	[locationController release];
	[super dealloc];

}


@end

