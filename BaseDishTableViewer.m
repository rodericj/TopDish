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
#import "DishDetailViewController.h"
#import "AppModel.h"

#define kMinimumToShowPercentage 2
@implementation BaseDishTableViewer

@synthesize tvCell = mTvCell;
@synthesize fetchedResultsController = mFetchedResultsController;
@synthesize managedObjectContext = mManagedObjectContext;
@synthesize responseData = mResponseData;
@synthesize addItemCell = mAddItemCell;
@synthesize entityTypeString = mEntityTypeString;
@synthesize conn = mConn;

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return c.bounds.size.height;
	//return DISHLISTCELLHEIGHT;
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
	if ([[[thisDish distance] stringValue] length] > 5) {
		distance.text = [[[thisDish distance] stringValue] substringToIndex:5];
	}
	else {
		distance.text = [[thisDish distance] stringValue];
	}
	
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
	
	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[imageView frame]];
	asyncImage.tag = 999;
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
		NSLog(@"url string for thisDish's image in BaseDishTableViewer is %@", urlString);
		
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


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self tableView:tableView dishCellAtIndexPath:indexPath];
	
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

-(void)dealloc{
	self.addItemCell = nil;
	
	self.entityTypeString = nil;
	self.addItemCell = nil;
	self.managedObjectContext = nil;
	self.fetchedResultsController = nil;
	self.responseData = nil;
	self.conn = nil;
	
	[super dealloc];
}
	

@end
