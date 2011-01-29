//
//  BaseDishTableViewer.m
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseDishTableViewer.h"
#import "constants.h"
#import "Dish.h"
#import "Restaurant.h"
#import "asyncimageview.h"
#import "RestaurantDetailViewController.h"
#import "AddNewDishViewController.h"
#import "DishDetailViewController.h"

@implementation BaseDishTableViewer

@synthesize tvCell = mTvCell;
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize _responseData;
@synthesize addItemCell = mAddItemCell;
@synthesize entityTypeString = mEntityTypeString;

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;
	//return DISHLISTCELLHEIGHT;
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
	NSLog(@"entity type string %@ and Managed Object Context = %@", self.entityTypeString, self.managedObjectContext);
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityTypeString inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	
    [self decorateFetchRequest:fetchRequest];
	
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

-(void)decorateFetchRequest:(NSFetchRequest *)request{

}

#pragma mark -
#pragma mark table view
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	//Return the Descriptor cell for adding a new dish
	if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:[indexPath section]] numberOfObjects])
		return self.addItemCell;
		
	//TODO RESTODISH SWITCH - Show a different cell for restaurants vs dishs
	
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
	NSString *restaurantName = [[thisDish restaurant] objName];
	resto.text = restaurantName;
	
	UILabel *cost;
	cost = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_COST_TAG];
	cost.text = @"$$$";

	UILabel *distance;
	distance = (UILabel *)[cell viewWithTag:DISHTABLEVIEW_DIST_TAG];
	if ([[[thisDish distance] stringValue] length] > 5) {
		distance.text = [[[thisDish distance] stringValue] substringToIndex:5];
	}
	else {
		distance.text = [[thisDish distance] stringValue];
	}

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
	
	NSMutableString *output = [NSMutableString stringWithCapacity:[[thisDish price] intValue]];
	
	for (int i = 0; i < [[thisDish price] intValue]; i++)
		[output appendString:@"$"];
	priceNumber.text = output;
	
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:DISHTABLEVIEW_IMAGE_TAG];
	
	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[imageView frame]];
	asyncImage.tag = 999;
	if( [[thisDish photoURL] length] > 0 ){
		NSLog(@"the dish photo URL is %@", [thisDish photoURL]);

		NSString *urlString = [NSString stringWithFormat:@"%@%@&w=%d&h=%d", 
							   NETWORKHOST, 
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
    // Configure the cell.
   // [self configureCell:cell atIndexPath:indexPath];
	//    }
	[cell setOpaque:FALSE];
	
    return cell;
}


#pragma mark -
#pragma mark other stuff
-(void) pushRestaurantViewController:(ObjectWithImage *) selectedObject{
	
	NSLog(@"goToRestaurantDetailView");
	RestaurantDetailViewController *detailViewController = [[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" bundle:nil];
	[detailViewController setRestaurant:(Restaurant *)selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[(Restaurant *)selectedObject objName]];
	[detailViewController release];
	
	//NSLog(@"RestaurantName from RestaurantTableViewController %@", [selectedObject objName]);
//	self.entityTypeString = @"Restaurant";
//	RestaurantDetailViewController *detailViewController = [[RestaurantDetailViewController alloc] init];
//	[detailViewController setRestaurant:(Restaurant*)selectedObject];
//	[detailViewController setManagedObjectContext:self.managedObjectContext];
//	
//	[self.navigationController pushViewController:detailViewController animated:YES];
//	[detailViewController setTitle:[selectedObject objName]];
//	[detailViewController release];
	
}
-(void) pushDishViewController:(ObjectWithImage *) selectedObject{
	NSLog(@"DishName from DishTableViewController %@", [selectedObject objName]);
	//self.entityTypeString = @"Dish";

	DishDetailViewController *detailViewController = [[DishDetailViewController alloc] initWithNibName:@"DishDetailViewController" bundle:nil];
	[detailViewController setThisDish:(Dish*)selectedObject];
	
	//[detailViewController setDish:(Dish*)selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[selectedObject objName]];
	[detailViewController release];
	
}

#pragma mark -
#pragma mark network connection stuff
-(void)processIncomingNetworkText:(NSString *)responseText{
	//Noop
	NSAssert(YES, @"assert, should have overridden processIncomingNetworkText");
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"connection did finish loading");
	NSString *responseText = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
	NSLog(@"response text before replacing %@", responseText);
	
	
	responseText = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	[self processIncomingNetworkText:responseText];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	NSLog(@"connection did fail with error %@", error);
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
#else	
	//Airplane mode must set _responseText
	[self processIncomingNetworkText:DishSearchResponseText];
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(_responseData == nil){
		_responseData = [[NSMutableData alloc] initWithData:data];
	}
	else{
		if (data) {
			[_responseData appendData:data];
		}
	}
}

-(void)dealloc{
	self.addItemCell = nil;
	[super dealloc];
}
	

@end
