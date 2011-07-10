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
#import "NearbyMapViewController.h"
#import "JSON.h"
#import "RestaurantTableViewCell.h"
#import "Logger.h"

#define kNumberOfSections 1
#define kRestaurantSection 0
#define kMaxDistance kOneMileInMeters * 25

@interface RestaurantList (Private)
-(void)updateFetch;
@end


@implementation RestaurantList

@synthesize fetchedResultsController = mFetchedResultsController;
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

	UIBarButtonItem *mapButton = [[[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:GLOBAL_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)] autorelease];
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
	
	NSArray *nearbyObjects = [self.fetchedResultsController fetchedObjects];
	[map setNearbyObjects:nearbyObjects];
	if ([nearbyObjects count]) 
		[self.navigationController pushViewController:map animated:TRUE];
	[map release];
	//[self presentModalViewController:map animated:TRUE];
}

-(void)viewWillAppear:(BOOL)animated {
    [Logger logEvent:kEventRTViewWillAppear];
	UISegmentedControl *s = (UISegmentedControl *) self.navigationItem.titleView;
	[s setSelectedSegmentIndex:1];
	[self updateFetch];
}

#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
	return kNumberOfSections;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//DLog(@"here we are using the managed Object %@", managedObject);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	//DLog(@"number of rows in section %d", [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects]);
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	return [sectionInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 95;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"RestaurantTableViewCell";
    
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	
	
    RestaurantTableViewCell *cell = (RestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RestaurantTableViewCell" owner:self options:nil];
        cell = (RestaurantTableViewCell *)[nib objectAtIndex:0];
        
        UIImage *backgroundImage = [UIImage imageNamed:@"gradient_1.png"];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[backgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:95]];
        [cell setBackgroundView:backgroundView];
        [backgroundView release];

	}
	cell.restaurantImageView.image = nil;
	cell.restaurantName.text = thisRestaurant.objName;
	cell.address.text = thisRestaurant.addressLine1;
	cell.phoneNumber.text = thisRestaurant.phone;
	
	NSAssert(thisRestaurant.distance > 0, @"the resto distance is not > 0");
	cell.distance.text = [NSString stringWithFormat:@"%.2f mi", [[thisRestaurant distance] floatValue]];	
	
	//Image handling
	if ([thisRestaurant.photoURL length] > 0) {
		if ([[AppModel instance] doesCacheItemExist:thisRestaurant.photoURL size:85]) {
			cell.restaurantImageView.image = [[AppModel instance] getImage:thisRestaurant.photoURL size:85];
		}
		else{
			dispatch_queue_t downloadQueue = dispatch_queue_create("com.topdish.imagedownload", NULL);
			
			//On background thread, download the image synchronously.
			dispatch_async(downloadQueue, ^{
				[[AppModel instance] getImage:thisRestaurant.photoURL size:85];
				
				//On the main thread, update the appropriate cell and the core data object
				dispatch_async(dispatch_get_main_queue(), ^{
					
					//only if this indexPath is visible do we need to set the imageview
					//  We've already set the core data object so there is no need to do anything else
					//  until it shows up again. This is so awesome
					if ([[tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
					}
				});
				dispatch_release(downloadQueue);
			});
		}
	}
	else {
		//show the default image
		cell.restaurantImageView.image = [UIImage imageNamed:@"no_rest_img.jpg"];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Restaurant *thisRestaurant = [[self fetchedResultsController] objectAtIndexPath:indexPath];	

	RestaurantDetailViewController *viewController = 
	[[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" 
													 bundle:nil];
	[viewController setRestaurant:thisRestaurant];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Restaurant" 
											  inManagedObjectContext:kManagedObjectContext];
    [fetchRequest setEntity:entity];
		
    // Set the batch size to a suitable number.
	fetchRequest.fetchLimit = kMinimumDishesToShow;
    // Edit the sort key as appropriate.
	
	// taken out so we can show the restaurant table results
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"posReviews" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DISTANCE_SORT ascending:TRUE];
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
	if (mUpdatingFetch) {
		return;
	}
	mUpdatingFetch = TRUE;
	DLog(@"updating the restaurant fetch");
	/*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
    // Edit the entity name as appropriate.
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Restaurant" 
											  inManagedObjectContext:kManagedObjectContext];
    [fetchRequest setEntity:entity];
    
	//Set up the filters that are stored in the AppModel
	NSMutableArray *filterPredicateArray = [NSMutableArray array];
	
	[self populatePredicateArray:filterPredicateArray];

	NSPredicate *fullPredicate = [NSCompoundPredicate 
								  andPredicateWithSubpredicates:filterPredicateArray]; 
	
	[fetchRequest setPredicate:fullPredicate];
	
	// Set the batch size to a suitable number.
	fetchRequest.fetchLimit = kMinimumDishesToShow;
	//Create array with sort params, then store in NSUserDefaults
	
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:DISTANCE_SORT 
								ascending:TRUE];
	
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
	
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
		
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
	DLog(@"reload the data");
	//Finally, reload the data with the latest fetch
	[self.tableView reloadData];
	
	mUpdatingFetch = FALSE;
}

-(void)saveRestaurantsComplete {
	[self performSelectorOnMainThread:@selector(updateFetch) withObject:self waitUntilDone:NO];
}

-(void)saveDishesComplete {
	DLog(@"the save of dishes is complete updateFetch in RestaurantList");
	[self performSelectorOnMainThread:@selector(updateFetch) withObject:self waitUntilDone:NO];
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
	CLLocation *l = [[AppModel instance] currentLocation];
	
	if (self.currentSearchTerm == nil) {
		self.currentSearchTerm = @"";
	}
	urlString = [NSString 
				 stringWithFormat:@"%@/api/restaurantSearch?lat=%.3f&lng=%.3f&distance=%d&limit=10&q=%@",
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
	
	
	//************Increase the search radius
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	[parser release];
	if ([[responseAsDictionary objectForKey:@"dishes"] count] < kMinimumDishesToShow && self.currentSearchDistance < kMaxDistance) {
		//Need to resend with a larger radius
		self.currentSearchDistance *= 5;
		
		//Need to remove self from the observer list so we don't get redundant notifications
		[self buildAndSendNetworkString];
	}
	//*************
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	//Send this incoming content to the IncomingProcessor Object
	NSPersistentStoreCoordinator *coord = [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
	
	IncomingProcessor *proc = [IncomingProcessor processorWithPersistentStoreCoordinator:coord Delegate:self];
	
	[[[AppModel instance] queue] addOperation:[proc taskWithData:responseTextStripped]];
	DLog(@"PROCESSOR  proc task is set up");
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
    [Logger logEvent:kEventRTSearchTextChanged];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.fetchedResultsController = nil;
	self.tableHeaderView;
	self.currentSearchTerm = nil;
	[mConnectionLookup release];
    [super dealloc];
}


@end
