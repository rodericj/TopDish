//
//  RootViewController.m
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Dish.h"
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
//@synthesize tableData;
@synthesize _responseText;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishSearch?lat=33.6886&lng=-117.8129&disance=200000", NETWORKHOST]];
	//Start up the networking
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLRequest *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Set up the edit and add buttons.
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(showSettings)];
	
    self.navigationItem.leftBarButtonItem = settingsButton;
	
	UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME] 
								  style:UIBarButtonItemStylePlain 
								  target:self 
								  action:@selector(flipToMap)];
	
	self.navigationItem.rightBarButtonItem = mapButton;

	[theTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tdlogo.png"]]];
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

	NSArray *nearbyObjects = [self.fetchedResultsController fetchedObjects];
	[map setNearbyObjects:nearbyObjects];
	//[map.navigationItem setRightBarButtonItem:mapButton];
	[self presentModalViewController:map animated:TRUE];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"posReviews" ascending:NO];
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
	NSURL *url = [NSURL URLWithString: [thisDish dish_photoURL]];
	//NSURL *url = [NSURL URLWithString:@"http://topdish1.appspot.com/getPhoto?id=84001"];
	[asyncImage loadImageFromURL:url withImageView:imageView showActivityIndicator:FALSE];
	[cell.contentView addSubview:asyncImage];
	
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSString *responseText = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSArray *responseAsArray = [parser objectWithString:responseText error:NULL];
	[parser release];
	[self.managedObjectContext reset];
	
	for (int i =0; i < [responseAsArray count]; i++){
		Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" inManagedObjectContext:self.managedObjectContext];
		NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
		[thisDish setDish_name:[thisElement objectForKey:@"name"]];
		[thisDish setPrice:[NSNumber numberWithInt:i+1]];
		[thisDish setDish_description:[thisElement objectForKey:@"description"]];
		[thisDish setDish_photoURL:[thisElement objectForKey:@"photoURL"]];
		[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
		[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
		[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
		[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
//	NSError *error;
//	NSArray *items = [self.managedObjectContext
//					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];	
	
	[responseText release];
	[_responseText release];
	_responseText = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"%@", error);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(_responseText == nil){
		_responseText = [[NSData alloc] initWithData:data];
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


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


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

