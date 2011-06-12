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
#import "DishDetailViewController.h"
#import "JSON.h"
#import "LoginModalView.h"

#define kTopDishBlue [UIColor colorWithRed:0 green:.3843 blue:.5725 alpha:1]
#define buttonLightBlue [UIColor colorWithRed:0 green:.73 blue:.89 alpha:1 ]
#define buttonLightBlueShine [UIColor colorWithRed:.53 green:.91 blue:.99 alpha:1]

#define kDishSection 0
#define kSearchCountLimit 25
#define kMaxDistance kOneMileInMeters * 25

#define sortStringArray [NSArray arrayWithObjects:@"nothing", DISTANCE_SORT, RATINGS_SORT, PRICE_SORT, nil]
@interface DishTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

-(NSString *) filterTagsList;

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
@synthesize fetchedResultsController = mFetchedResultsController;
@synthesize currentSortIndicator = mCurrentSortIndicator;

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
	UIBarButtonItem *settingsButton = [[[UIBarButtonItem alloc] 
									   initWithImage:[UIImage imageNamed:FILTER_IMAGE_NAME] 
									   style:UIBarButtonItemStylePlain 
									   target:self 
									   action:@selector(showSettings)] autorelease];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	// Set up the map button
	UIBarButtonItem *mapButton = [[[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:GLOBAL_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)] autorelease];
	
	self.navigationItem.rightBarButtonItem = mapButton;
	
	[self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
	self.title = @"Dishes";
	
}

-(void)addObservers {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(buildRestaurantNetworkGrab:) 
												 name:NSNotificationStringDoneProcessingDishes 
											   object:nil];
}
-(void)removeObservers {

	
}
- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = kTopDishBackground;
	self.tableView.backgroundColor = kTopDishBackground;
	self.navigationController.navigationBar.tintColor = kTopDishBlue;
	[self setUpSpecificView];
	[self addObservers];
	
}
-(void)viewDidAppear:(BOOL)animated {
	AppModel *app = [AppModel instance];
	if (![app isLoggedIn] && !app.userDelayedLogin) {
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:NO];
	}
	UIImage *filterImage = ([app isAnyFilterSet]) ? 
	[UIImage imageNamed:FILTER_ON_IMAGE_NAME] : [UIImage imageNamed:FILTER_IMAGE_NAME];
	
	[self.navigationItem.leftBarButtonItem setImage:filterImage];

	[self updateFetch];
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
	[mConnectionLookup setObject:[NSMutableData data] forKey:conn];
	[conn release];
}

-(void)buildAndSendNetworkString{
	NSString *urlString; 
	CLLocation *currentLoc = [[AppModel instance] currentLocation];
	
	//If we don't have a location yet, bail (it's the middle 
	//of the Lower Atlantic, Noone will ever be there.
	if (!currentLoc) 
		return;
	
	if (self.currentSearchTerm == nil) {
		self.currentSearchTerm = @"";
	}
	
	urlString = [NSString 
				 stringWithFormat:@"%@/api/dishSearch?lat=%.3f&lng=%.3f&distance=%d&limit=%d&tags=%@&q=%@",
				 NETWORKHOST,
				 currentLoc.coordinate.latitude,
				 currentLoc.coordinate.longitude, 
				 self.currentSearchDistance,
				 kSearchCountLimit,
				 [self filterTagsList],
				 [self.currentSearchTerm lowercaseString]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[self networkQuery:urlString];
}

// Implement viewWillAppear: to do additional setup before the view is presented.
- (void)viewWillAppear:(BOOL)animated {
	//do we need to update the fetch when we come back?
	//   I say yes in case we come back from settings
	[self buildAndSendNetworkString];
	[self updateFetch];
	[super viewWillAppear:animated];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//DLog(@"here we are using the managed Object %@", managedObject);
}

#pragma mark -
#pragma mark nav bar buttons
- (void) showSettings {
	AppModel *app = [AppModel instance];
	if ([app priceTags] && [app cuisineTypeTags] && [app mealTypeTags]) {
		SettingsView1 *settings = [[SettingsView1 alloc] initWithNibName:@"SettingsView1" bundle:nil];
		[settings setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		[self.navigationController pushViewController:settings animated:TRUE];
		[settings release];
	}
}

- (void) flipToMap {
	
	if ([self.tableView numberOfRowsInSection:kDishSection] > 0) {
		
		NearbyMapViewController *map = [[NearbyMapViewController alloc] 
										initWithNibName:@"NearbyMapView" 
										bundle:nil];
		map.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		
		map.nearbyObjects = [self.fetchedResultsController fetchedObjects];
		[self.navigationController pushViewController:map animated:TRUE];
		[map release];
	}
}

#pragma mark -
#pragma mark network connection stuff

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	DLog(@"request complete ---------------------");
	NSData *thisResponseData = [mConnectionLookup objectForKey:theConnection];

	NSString *responseText = [[NSString alloc] initWithData:thisResponseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	DLog(@"Set up the background processor for this incoming data");
	//Send this incoming content to the IncomingProcessor Object
	NSPersistentStoreCoordinator *coord = [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
	
	IncomingProcessor *proc = [IncomingProcessor processorWithPersistentStoreCoordinator:coord Delegate:self];
	//IncomingProcessor *proc = [[IncomingProcessor alloc] initWithProcessorDelegate:self];
	
	[[[AppModel instance] queue] addOperation:[proc taskWithData:responseTextStripped]];
	[proc release];	
	
	//************Increase the search radius
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
			[self buildAndSendNetworkString];
		}
	
	[parser release];
	//*************

	[responseText release];
	
}

-(void)notifySaveComplete {
	[[NSNotificationCenter defaultCenter] notifySaveComplete];
	//[[NSNotificationCenter defaultCenter] postNotification:NSManagedObjectContextDidSaveNotification];
}

-(void)doSaveRestaurantsComplete {
	[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneProcessingRestaurants
														object:self 
													  userInfo:nil];
	[self updateFetch];
}

-(void)saveRestaurantsComplete {
	NSLog(@"send notification about save restaurants complete");
	[self performSelectorOnMainThread:@selector(doSaveRestaurantsComplete) 
						   withObject:self 
						waitUntilDone:NO];
}

-(void)doSaveDishesComplete {
	[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneProcessingDishes
														object:self 
													  userInfo:nil];	
}

-(void)saveDishesComplete {
	DLog(@"the save of dishes is complete in DishTableView");
	[self performSelectorOnMainThread:@selector(doSaveDishesComplete) withObject:self waitUntilDone:NO];
}

-(void)buildRestaurantNetworkGrab:(NSNotification *)notification {
	DLog(@"begin the network request to get the restaurants");
		
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
	[mConnectionLookup removeObjectForKey:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	NSMutableData *thisResponseData = [mConnectionLookup objectForKey:connection];
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

-(NSString *) filterTagsList {
	AppModel *app = [AppModel instance];
	
	
	return [NSString stringWithFormat:@"%@,%@,%@,%@,%@", 
			app.selectedPrice ? app.selectedPrice : @"", 
			app.selectedMeal ? app.selectedMeal : @"",
			app.selectedCuisine ? app.selectedCuisine : @"", 
			app.selectedAllergen ? app.selectedAllergen : @"", 
			app.selectedLifestyle ? app.selectedLifestyle : @""];
	
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
			  @"price", [app selectedPrice]);
		
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",
						   attributeName, attributeValue];
		
		DLog(@"the real predicate is %@", filterPredicate);
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on price
	if ([[app selectedPrice] intValue] != 0) {
		
		DLog(@"the else predicate %@ == %d", 
			  @"price", [app selectedPrice]);
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"price", [app selectedPrice]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on mealType
	if ([[app selectedMeal] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"mealType", [app selectedMeal]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on cuisine
	if ([[app selectedCuisine] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"cuisineType", [app selectedCuisine]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on allergen
	if ([[app selectedAllergen] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"allergenType", [app selectedAllergen]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	
	//Filter based on lifestyle
	if ([[app selectedLifestyle] intValue] != 0) {
		filterPredicate = [NSPredicate predicateWithFormat: @"%K == %@", 
						   @"lifestyleType", [app selectedLifestyle]];
		
		[filterPredicateArray addObject:filterPredicate];
	}
	[filterPredicateArray addObject:[NSPredicate predicateWithFormat:@"%K < %d", @"distance", 
									 self.currentSearchDistance]];

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
											  inManagedObjectContext:kManagedObjectContext];
    fetchRequest.entity = entity;
	//Set up the filters that are stored in the AppModel
	NSMutableArray *filterPredicateArray = [NSMutableArray array];
	
	[self populatePredicateArray:filterPredicateArray];
	
	if ([self respondsToSelector:@selector(restaurantDetailFilter)])
		[filterPredicateArray addObject:[self restaurantDetailFilter]];
	
	NSPredicate *fullPredicate = [NSCompoundPredicate 
								  andPredicateWithSubpredicates:filterPredicateArray]; 

	[fetchRequest setPredicate:fullPredicate];

	// Set the batch size to a suitable number.
	fetchRequest.fetchLimit = kMinimumDishesToShow;
	
	//Create array with sort params, then store in NSUserDefaults
	BOOL ascending = TRUE;
	int sorterValue = [[AppModel instance] sorter];
	if (sorterValue < 0) {
		ascending = FALSE;
		sorterValue = -sorterValue;
	}
	
	NSString *sorter = [sortStringArray objectAtIndex:sorterValue];
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
										managedObjectContext:kManagedObjectContext 
										  sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
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
		
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[selectedObject objName]];
	[detailViewController release];
	
}


#pragma mark -
#pragma mark table view
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 95;
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
	DishTableViewCell *cell = (DishTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DishTableViewCell" owner:self options:nil];
        cell = (DishTableViewCell *)[nib objectAtIndex:0];
	}
	
	//remove any image that was loaded previously
	cell.dishImageView.image = nil;
	
	//Query the results controller
	Dish *thisDish = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	
	//Build the UIElements
	cell.dishName.text = thisDish.objName;
	cell.restaurantName.text = thisDish.restaurant.objName;
	
	AppModel *app = [AppModel instance];
	cell.mealType.text = [app tagNameForTagId:thisDish.mealType];
	
	CLLocation *l = [[CLLocation alloc] initWithLatitude:[thisDish.latitude floatValue] 
											   longitude:[thisDish.longitude floatValue]];
	CLLocationDistance dist = [l distanceFromLocation:[AppModel instance].currentLocation];
	[l release];
	
	if (dist != -1) {
		//convert from meters to miles
		float distanceInMiles = dist/kOneMileInMeters; 
		NSAssert(distanceInMiles > 0, @"the distance is not > 0");
		cell.distance.text = [NSString stringWithFormat:@"%2.2f", distanceInMiles];	
	}
	else
		//Let's just set the text to blank until the current location is determined, at which 
		//point, we'll update the fetch, which will update the cell
		cell.distance.text = @"";
	
	cell.upVotes.text = [NSString stringWithFormat:@"+%@", 
					thisDish.posReviews];
	cell.downVotes.text = [NSString stringWithFormat:@"-%@", 
					  thisDish.negReviews];
	
	if (thisDish.posReviews > thisDish.negReviews){
		cell.upVotes.font =[UIFont boldSystemFontOfSize:28.0];
		cell.downVotes.font =[UIFont boldSystemFontOfSize:20.0];
	}else if([thisDish posReviews] < [thisDish negReviews]){
		cell.upVotes.font =[UIFont boldSystemFontOfSize:20.0];
		cell.downVotes.font =[UIFont boldSystemFontOfSize:28.0];
	}else{
		cell.upVotes.font =[UIFont boldSystemFontOfSize:24.0];
		cell.downVotes.font =[UIFont boldSystemFontOfSize:24.0];
	}
	
	cell.priceNumber.text = [app tagNameForTagId:[thisDish price]];
	
	//Image handling
	if ([thisDish.photoURL length] > 0) {
		if (thisDish.imageData) {
			cell.dishImageView.image = [UIImage imageWithData:thisDish.imageData];
		}
		else{
			dispatch_queue_t downloadQueue = dispatch_queue_create("com.topdish.imagedownload", NULL);
			dispatch_retain(downloadQueue);
			
			//On background thread, download the image synchronously.
			dispatch_async(downloadQueue, ^{
				//Set up URL and download image (all in the background)
				NSURL *imageUrl = [NSURL URLWithString:thisDish.photoURL];
				NSData *data = [NSData dataWithContentsOfURL:imageUrl];
				UIImage *image = [UIImage imageWithData:data];
				
				//Update the core data object
				thisDish.imageData = data;
				
				//On the main thread, update the appropriate cell and the core data object
				dispatch_async(dispatch_get_main_queue(), ^{
					
					//only if this indexPath is visible do we need to set the imageview
					//  We've already set the core data object so there is no need to do anything else
					//  until it shows up again. This is so awesome
					if ([[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
						cell.dishImageView.image = image;
					}
					else {
						NSLog(@"%@ is not visible", thisDish.objName);
					}

				});
				
			});
			dispatch_release(downloadQueue);
		}
	}
	else {
		//show the default image
		cell.dishImageView.image = [UIImage imageNamed:@"no_dish_img.png"];
	}

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
	
	[UIView beginAnimations:@"distanceSort" context:NULL]; // Begin animation
	
	[self.currentSortIndicator setFrame:CGRectMake(176, 44, 29, 28)]; // Move imageView off screen
	
	if ([[AppModel instance] sorter] == kSortByDistance) {
		[[AppModel instance] setSorter:-kSortByDistance];
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(M_PI);
	}
	else {
		[[AppModel instance] setSorter:kSortByDistance];
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(0);
	}

	[UIView commitAnimations]; // End animations

	[self updateFetch];
}
-(IBAction) sortByRating
{
	[UIView beginAnimations:@"ratingSort" context:NULL]; // Begin animation

	[self.currentSortIndicator setFrame:CGRectMake(281, 44, 29, 28)]; // Move imageView off screen

	DLog(@"sort by Rating %d", [[AppModel instance] sorter]);
	if ([[AppModel instance] sorter] == -kSortByRating) {
		[[AppModel instance] setSorter:kSortByRating];
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(M_PI);
	}
	else {
		[[AppModel instance] setSorter:-kSortByRating];	
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(0);

	}
	[UIView commitAnimations]; // End animations
	[self updateFetch];
}
-(IBAction) sortByPrice
{
	[UIView beginAnimations:@"priceSort" context:NULL]; // Begin animation

	[self.currentSortIndicator setFrame:CGRectMake(70, 44, 29, 28)]; // Move imageView off screen

	DLog(@"sort by Price");
	
	if ([[AppModel instance] sorter] == kSortByPrice) {
		[[AppModel instance] setSorter:-kSortByPrice];
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(M_PI);
	}
	else {
		[[AppModel instance] setSorter:kSortByPrice];
		self.currentSortIndicator.transform = CGAffineTransformMakeRotation(0);
	}
	[UIView commitAnimations]; // End animations

	[self updateFetch];
}

#pragma mark -
#pragma mark Location
- (void)locationError:(NSError *)error {
	DLog(@"Error getting location %@", error);
}
	
- (void)locationUpdate:(CLLocation *)location {
	if ([location distanceFromLocation:[AppModel instance].currentLocation] > 10) {
				
		[self buildAndSendNetworkString];
		
		NSPersistentStoreCoordinator *coord = [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
		DistanceUpdator *proc = [DistanceUpdator updatorWithPersistentStoreCoordinator:coord Delegate:self];
		[[[AppModel instance] queue] addOperation:[proc taskWithData:nil]];
		
		if (!locationController) {
			locationController = [[MyCLController alloc] init];
		}
		locationController.delegate = self;
	}
	[[AppModel instance] setCurrentLocation:location];

	//[locationController.locationManager stopUpdatingLocation];
}


#pragma mark DistanceUpdatorDelegate
-(void)distancesUpdatedOnMain {
	[self.tableView reloadData];
}

-(void)distancesUpdated {
	[self performSelectorOnMainThread:@selector(distancesUpdatedOnMain) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark LoginModalView Delegate
-(void)loginStarted {
	NSLog(@"the login started");
}

-(void)facebookLoginComplete {
	NSLog(@"facebook login complete, waiting for TD login, lets move forward");
}
-(void)loginFailed {
	NSLog(@"the login failed");
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Login To TopDish Failed" 
												 message:@"Please try again later" 
												delegate:nil 
									   cancelButtonTitle:@"Ok" 
									   otherButtonTitles:nil];
	[av show];
	[av release];
	[[AppModel instance].facebook logout:[AppModel instance]];
}
-(void)loginComplete {
	NSLog(@"the login from the LoginModalView was complete");
	[self dismissModalViewControllerAnimated:YES];
}

-(void)noLoginNow {
	NSLog(@"the not now button was pressed");
	[self dismissModalViewControllerAnimated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" inManagedObjectContext:kManagedObjectContext];
    [fetchRequest setEntity:entity];
		
    // Set the batch size to a suitable number.
	fetchRequest.fetchLimit = kMinimumDishesToShow;

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
															 managedObjectContext:kManagedObjectContext 
															 sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
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
	self.currentSearchTerm = nil;
	[self updateFetch];
}	

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	DLog(@"the search bar text changed %@", searchText);
	
	//Send the network request
	self.currentSearchTerm = searchText;
	[self buildAndSendNetworkString];
	
	//Limit the core data output
	[self updateFetch];
}

- (void)dealloc {

	DLog(@"************************************* Dealloc. This probably shouldn't happen too often");
	self.addItemCell = nil;
	self.tvCell = nil;
	self.currentSortIndicator = nil;
	self.currentSearchTerm = nil;
	
	self.bgImage = nil;
	
	self.theSearchBar = nil;
	self.searchHeader = nil;
	
	self.ratingTextLabel = nil;
	self.priceTextLabel = nil;
	self.distanceTextLabel = nil;
	
	self.fetchedResultsController = nil;
	
	[mConnectionLookup release];
	[locationController release];
	[super dealloc];

}


@end

