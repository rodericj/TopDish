//
//  DishTableViewer.m
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DishTableViewer.h"
#import "constants.h"
#import "Dish.h"
#import "asyncimageview.h"
#import "ScrollingDishDetailViewController.h"

@implementation DishTableViewer

@synthesize tvCell;
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize _responseData;
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
	dishName.text = thisDish.objName;
	
	UILabel *resto;
	resto = (UILabel *)[cell viewWithTag:ROOTVIEW_RESTAURANT_NAME_TAG];
	resto.text = @"Resto Name";
	NSString *restaurantName = [[thisDish restaurant] objName];
	int length = [restaurantName length];
	if (length > MAXRESTAURANTNAMELENGTH){
		restaurantName = [restaurantName substringToIndex:MAXRESTAURANTNAMELENGTH];
	}
	resto.text = restaurantName;
	
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
	if( [[thisDish photoURL] length] > 0 ){
		NSString *urlString = [NSString stringWithFormat:@"%@&w=70&h=70", [thisDish photoURL]];
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		[asyncImage setOwningObject:thisDish];
		[asyncImage loadImageFromURL:photoUrl withImageView:imageView showActivityIndicator:FALSE];
		[cell.contentView addSubview:asyncImage];
	}
    // Configure the cell.
   // [self configureCell:cell atIndexPath:indexPath];
	//    }
	[cell setOpaque:FALSE];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO RESTODISH SWITCH - The drilldown for restaurants and dishes are different in the detailviewcontroller
	
    // Navigation logic may go here -- for example, create and push another view controller.
	Dish *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	NSLog(@"DishName from RootView Controller %@", [selectedObject objName]);
	
	ScrollingDishDetailViewController *detailViewController = [[ScrollingDishDetailViewController alloc] initWithNibName:@"ScrollingDishDetailView" bundle:nil];
	
	[detailViewController setDish:selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[selectedObject objName]];
	[detailViewController release];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"connection did finish loading");
	NSString *responseText = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
	//NSLog(@"response text before replacing %@", responseText);
	
	
	responseText = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	NSLog(@"response text after replacing %@", responseText);
	[self processIncomingNetworkText:responseText];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"connection did fail with error %@", error);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
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

@end
