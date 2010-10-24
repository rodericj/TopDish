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

@interface CommentsTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation CommentsTableViewController
@synthesize dishId;
@synthesize managedObjectContext;
@synthesize reviews;
@synthesize commentCell;
@synthesize _responseText;
@synthesize fetchedResultsController;

//#pragma mark -
//#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"here we are using the managed Object %@", managedObject);
}

-(void)refreshFromServer{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", NETWORKHOST, dishId]];
	//Start up the networking
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

	return cell;
}

#pragma mark -
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSString *responseText = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
	
	//If I add these dummies in I need to make them arrays
	//responseText = @"{\"id\":38, \"name\":\"Bacon Burger\", \"Description\":\"All bacon and bun\", \"restaurantID\":37, \"latitude\":33.677854, \"longitude\":-117.799428, \"posReviews\":1, \"negReviews\":2, \"photoURL\":\"\", \"reviews\":[{\"direction\":1, \"comment\": \"yo this thing was great\",\"creator\":\"andy\", \"dateCreated\":\"oct 11, 2010 4:39:42 AM\"},{\"direction\":-1, \"comment\": \"I've been sad all of my life\",\"creator\":\"Marcus\", \"dateCreated\":\"oct 12, 2010 4:49:42 AM\"},{\"direction\":-1, \"comment\": \"I've been sad all of my life\",\"creator\":\"Marcus\", \"dateCreated\":\"oct 12, 2010 4:49:42 AM\"},{\"direction\":-1, \"comment\": \"MATT DAMON\",\"creator\":\"Matt Damon\", \"dateCreated\":\"oct 12, 2010 4:39:42 AM\"}]}"; 
	//responseText = @"{\"id\":38, \"name\":\"Bacon Burger\", \"Description\":\"All bacon and bun\", \"restaurantID\":37, \"latitude\":33.677854, \"longitude\":-117.799428, \"posReviews\":1, \"negReviews\":2, \"photoURL\":\"\", \"reviews\":[{\"direction\":1, \"comment\": \"yo this thing was great\",\"creator\":\"andy\", \"dateCreated\":\"oct 11, 2010 4:39:42 AM\"},{\"direction\":-1, \"comment\": \"I've been sad all of my life\",\"creator\":\"Marcus\", \"dateCreated\":\"oct 12, 2010 4:49:42 AM\"},{\"direction\":-1, \"comment\": \"I've been sad all of my life\",\"creator\":\"Marcus\", \"dateCreated\":\"oct 12, 2010 4:49:42 AM\"},{\"direction\":-1, \"comment\": \"I've been sad all of my life\",\"creator\":\"Marcus\", \"dateCreated\":\"oct 12, 2010 4:49:42 AM\"},{\"direction\":-1, \"comment\": \"MATT DAMON\",\"creator\":\"Matt Damon\", \"dateCreated\":\"oct 12, 2010 4:39:42 AM\"}]}"; 
	
	SBJSON *parser = [SBJSON new];
	NSError *error;
	NSArray *responseAsArray = [parser objectWithString:responseText error:&error];
	NSDictionary *thisDishDetailDictionary = [responseAsArray objectAtIndex:0];
	NSLog(@"%@", thisDishDetailDictionary);
	//NSLog(@"%@", thisDishDetailDictionary);
	[parser release];
	if(reviews == nil){
		NSLog(@"allocate the array the first time");
		reviews = [NSArray alloc];
	}
	reviews = [[thisDishDetailDictionary objectForKey:@"reviews"] copy];
	
	//I'm going to do this the stupid way:
	//TODO should probably put this into CoreData
	
	
//	for (int i =0; i < [responseAsDictionary count]; i++){
//		DishComment *thisDishComment = (DishComment *)[NSEntityDescription insertNewObjectForEntityForName:@"DishComment" inManagedObjectContext:self.managedObjectContext];
//		NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
//		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
//		[thisDish setDish_name:[thisElement objectForKey:@"name"]];
//		[thisDish setDish_description:[thisElement objectForKey:@"description"]];
//		[thisDish setDish_photoURL:[thisElement objectForKey:@"photoURL"]];
//		[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
//		[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
//		[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
//		[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
//		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
//	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	//NSError *error;
	//NSArray *items = [self.managedObjectContext
//					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];	
	
	[responseText release];
	[_responseText release];
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

