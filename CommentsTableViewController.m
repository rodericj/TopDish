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
#import "RateDishViewController.h"
#import "RestaurantDetailViewController.h"

@interface CommentsTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CommentsTableViewController
@synthesize dish = mDish;
@synthesize managedObjectContext;
@synthesize reviews = mReviews;
@synthesize commentCell;
@synthesize addRatingCell = mAddRatingCell;
@synthesize pushRestaurantCell = mPushRestaurantCell;
@synthesize responseText = mResponseText;
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

-(void)refreshFromServer{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", NETWORKHOST, [self.dish dish_id]]];
	//Start up the networking
	NSLog(@"the comments url is %@", url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
	if(!self.reviews){
		return 2;
	}
	
	return [self.reviews count]+2;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row == [self.reviews count]) {
		[self pushRateViewController];
	}
	if (indexPath.row == [self.reviews count]+1) {
		[self goToRestaurantDetailView];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CommentControllerTableViewCell" owner:self options:nil];
		if (indexPath.row == [self.reviews count]) {
			return self.addRatingCell;
		}
		if (indexPath.row == [self.reviews count]+1) {
			return self.pushRestaurantCell;
		}
		cell = commentCell;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
    // Configure the cell...
	NSDictionary *thisReview = [self.reviews objectAtIndex:[indexPath row]];
	
	UILabel *commentorName;
	commentorName = (UILabel *)[cell viewWithTag:COMMENTOR_NAME_TAG];
	commentorName.text = [thisReview objectForKey:@"creator"];
	
	UILabel *commentText;
	commentText = (UILabel *)[cell viewWithTag:COMMENT_TEXT_TAG];
	commentText.text = [NSString stringWithFormat:@"\"%@\"", [thisReview objectForKey:@"comment"]];

	UIImageView *im = (UIImageView *)[cell viewWithTag:COMMENT_DIRECTION_IMAGE_TAG];
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
	NSString *responseText = [[NSString alloc] initWithData:self.responseText encoding:NSUTF8StringEncoding];
		
	SBJSON *parser = [SBJSON new];
	NSError *error;
	NSArray *responseAsArray = [parser objectWithString:responseText error:&error];
	NSDictionary *thisDishDetailDictionary = [responseAsArray objectAtIndex:0];
	NSLog(@"thisdishdetaildictionary %@", thisDishDetailDictionary);
	//NSLog(@"%@", thisDishDetailDictionary);
	[parser release];
	if(self.reviews == nil){
		NSLog(@"allocate the array the first time");
		self.reviews = [NSArray alloc];
	}
	self.reviews = [[thisDishDetailDictionary objectForKey:@"reviews"] copy];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest release];	
	[responseText release];
	self.responseText = nil;
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
	if(self.responseText == nil){
		self.responseText = data;
		//self.responseText = [[NSData alloc] initWithData:data];
	}
}

#pragma mark -
#pragma mark actions

-(IBAction) pushRateViewController{
	RateDishViewController *rateDish = [[RateDishViewController alloc] init];
	[rateDish setDish:self.dish];
	[self.navigationController pushViewController:rateDish animated:YES];
	[rateDish release];
}

-(IBAction) goToRestaurantDetailView{
	NSLog(@"goToRestaurantDetailView");
	RestaurantDetailViewController *detailViewController = [[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" bundle:nil];
	[detailViewController setRestaurant:[self.dish restaurant]];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[[self.dish restaurant] objName]];
	[detailViewController release];
}

- (void)dealloc {
	self.reviews = nil;
    [super dealloc];
	NSLog(@"done deallocing comments");
}


@end

