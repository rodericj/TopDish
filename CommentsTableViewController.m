//
//  CommentsTableViewController.m
//  TopDish
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "constants.h"
#import "JSON.h"
#import "DishComment.h"
#import "ScrollingDishDetailViewController.h"

@interface CommentsTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CommentsTableViewController
@synthesize dishId;
@synthesize dish = mDish;
@synthesize managedObjectContext;
@synthesize reviews;
@synthesize commentCell;
@synthesize _responseText;
@synthesize fetchedResultsController;
@synthesize commentDirection;

//#pragma mark -
//#pragma mark Initialization

-(void)viewDidLoad{
	[super viewDidLoad];
	ScrollingDishDetailViewController *detailViewController = [[ScrollingDishDetailViewController alloc] initWithNibName:@"ScrollingDishDetailView" bundle:nil];
	[detailViewController setDish:self.dish];
	NSLog(@"the dish is %@", self.dish);
	[self.tableView setTableHeaderView:detailViewController.view];
	[self refreshFromServer];
}

#pragma mark -
#pragma mark View lifecycle

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"here we are using the managed Object %@", managedObject);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 40;

}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//	ScrollingDishDetailViewController *detailViewController = [[ScrollingDishDetailViewController alloc] initWithNibName:@"ScrollingDishDetailView" bundle:nil];
//	[detailViewController setDish:self.dish];
//	return detailViewController.view;
//}
-(void)refreshFromServer{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", NETWORKHOST, [self.dish dish_id]]];
	//Start up the networking
	NSLog(@"the comments url is %@", url);
	request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(reviews == nil){
		return 0;
	}
	
	return [reviews count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CommentControllerTableViewCell" owner:self options:nil];
		cell = commentCell;
	}
	
    // Configure the cell...
	NSDictionary *thisReview = [reviews objectAtIndex:[indexPath row]];
	
	UILabel *commentorName;
	commentorName = (UILabel *)[cell viewWithTag:COMMENTOR_NAME_TAG];
	commentorName.text = [thisReview objectForKey:@"creator"];
	
	UILabel *commentText;
	commentText = (UILabel *)[cell viewWithTag:COMMENT_TEXT_TAG];
	commentText.text = [NSString stringWithFormat:@"\"%@\"", [thisReview objectForKey:@"comment"]];

	UIImageView *im = (UIImageView *)[cell viewWithTag:COMMENT_DIRECTION_IMAGE_TAG];
	NSLog(@"direction %d", [thisReview objectForKey:@"direction"]);
	if([[thisReview objectForKey:@"direction"] intValue] == 1){
		[im setImage:[UIImage imageNamed:POSITIVE_REVIEW_IMAGE_NAME]];
	}
	else{
		[im setImage:[UIImage imageNamed:NEGATIVE_REVIEW_IMAGE_NAME]];
	}
	return cell;
}

#pragma mark -
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSString *responseText = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
		
	SBJSON *parser = [SBJSON new];
	NSError *error;
	NSArray *responseAsArray = [parser objectWithString:responseText error:&error];
	NSDictionary *thisDishDetailDictionary = [responseAsArray objectAtIndex:0];
	NSLog(@"thisdishdetaildictionary %@", thisDishDetailDictionary);
	//NSLog(@"%@", thisDishDetailDictionary);
	[parser release];
	if(reviews == nil){
		NSLog(@"allocate the array the first time");
		reviews = [NSArray alloc];
	}
	reviews = [[thisDishDetailDictionary objectForKey:@"reviews"] copy];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest release];	
	[responseText release];
	//[_responseText release];
	_responseText = nil;
	[self.tableView reloadData];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"This is the dish detail error %@", error);
	
	//TODO when the server is in a bit better shape I'll have to 
	//remove this default call as well as the hard coded data
	[self connectionDidFinishLoading:connection];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];	
#endif
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(_responseText == nil){
		_responseText = [[NSData alloc] initWithData:data];
	}
}

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
	[reviews release];
	[request release];
    [super dealloc];
}


@end

