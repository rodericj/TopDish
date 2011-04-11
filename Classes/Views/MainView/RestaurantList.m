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

#define kNumberOfSections 1
#define kRestaurantSection 0
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
	self.currentSearchDistance = kOneMileInMeters;
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

-(void)viewWillDisappear:(BOOL)animated {
	NSEnumerator *enumerator = [mConnectionLookup keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		/* code that uses the returned key */
		DLog(@"cancel this connection");
		NSURLConnection *conn = (NSURLConnection *)key;
		[conn cancel];
	}	
	
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
	return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	DLog(@"number of rows in section %d", [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects]);
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	return [sectionInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"RestaurantTableViewCell";
    
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	
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
	
	NSAssert(thisRestaurant.distance > 0, @"the resto distance is not > 0");
	distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", [[thisRestaurant distance] floatValue]];	
	
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
		restaurantImageView.image = [UIImage imageNamed:@"no_rest_img.jpg"];

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
	fetchRequest.fetchLimit = 10;
    // Edit the sort key as appropriate.
	
	// taken out so we can show the restaurant table results
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"posReviews" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DISTANCE_SORT ascending:TRUE];
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
		DLog(@"the predicate we are sending: %@ contains(cd) %@",
			 attributeName, attributeValue);
		
		filterPredicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@",
						   attributeName, attributeValue];
		
		DLog(@"the real predicate is %@", filterPredicate);
		[filterPredicateArray addObject:filterPredicate];
	}
		
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
	fetchRequest.fetchLimit = 10;
	//Create array with sort params, then store in NSUserDefaults
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:DISTANCE_SORT 
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
	
	DLog(@"perform the fetch %@", fetchRequest);
	
    NSError *error = nil;
    if (![mFetchedResultsController performFetch:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	DLog(@"reload the data");
	//Finally, reload the data with the latest fetch
	[self.tableView reloadData];
	
}

-(void)saveComplete {
	DLog(@"the save is complete");
	[self performSelectorOnMainThread:@selector(updateFetch) withObject:nil waitUntilDone:NO];

	//[self updateFetch];
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
	
	DLog(@"Segmentedcontrol changed, the fetchedResults controller is %@", 
		 self.fetchedResultsController);
	
	NSString *urlString; 
	CLLocation *l = [[AppModel instance] currentLocation];
	
	if (self.currentSearchTerm == nil) {
		self.currentSearchTerm = @"";
	}
	urlString = [NSString 
				 stringWithFormat:@"%@/api/restaurantSearch?lat=%f&lng=%f&distance=%d&limit=5&q=%@",
				 NETWORKHOST,
				 l.coordinate.latitude,
				 l.coordinate.longitude, 
				 self.currentSearchDistance,
				 [self.currentSearchTerm lowercaseString]];
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	[self networkQuery:urlString];
}

#pragma mark -
#pragma mark network connection stuff

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSData *thisResponseData = [mConnectionLookup objectForKey:theConnection];

	NSString *responseText = [[NSString alloc] initWithData:thisResponseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	//Send this incoming content to the IncomingProcessor Object
	IncomingProcessor *proc = [IncomingProcessor processorWithDelegate:self];
	
	[[[AppModel instance] queue] addOperation:[proc taskWithData:responseTextStripped]];
	DLog(@"PROCESSOR  proc task is set up");
	[proc release];
	[responseText release];
	
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


#pragma mark -
#pragma mark Search delegate functions

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	self.currentSearchTerm = nil;
	[searchBar resignFirstResponder];
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
	[mConnectionLookup release];
    [super dealloc];
}


@end
