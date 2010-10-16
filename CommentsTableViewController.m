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

/*
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"here we are using the managed Object %@", managedObject);
}

-(void)refreshFromServer{
	NSLog(@"the dish id is %@", dishId);
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id=%@", NETWORKHOST, dishId]];
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	 
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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
    NSLog(@"set the text of the table view cells to test");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
    
	if (cell == nil) {
		NSLog(@"the cell is null. Must get it");
        [[NSBundle mainBundle] loadNibNamed:@"CommentControllerTableViewCell" owner:self options:nil];
		cell = commentCell;
	}
	
    // Configure the cell...
	NSDictionary *thisReview = [reviews objectAtIndex:[indexPath row]];
    //cell.text = [thisReview objectForKey:@"comment"];
	
	UILabel *commentorName;
	commentorName = (UILabel *)[cell viewWithTag:COMMENTOR_NAME_TAG];
	commentorName.text = [thisReview objectForKey:@"creator"];
	
	UILabel *commentText;
	commentText = (UILabel *)[cell viewWithTag:COMMENT_TEXT_TAG];
	commentText.text = [NSString stringWithFormat:@"\"%@\"", [thisReview objectForKey:@"comment"]];
//	[self configureCell:cell atIndexPath:indexPath];

	NSLog(@"%@", [thisReview objectForKey:@"creator"]);
	NSLog(@"%@", [thisReview objectForKey:@"comment"]);
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"%@", _responseText);
	NSString *responseText = [[NSString alloc] initWithData:_responseText encoding:NSUTF8StringEncoding];
	responseText = @"{\"id\":38, \"name\":\"Bacon Burger\", \"Description\":\"All bacon and bun\", \"restaurantID\":37, \"latitude\":33.677854, \"longitude\":-117.799428, \"posReviews\":1, \"negReviews\":2, \"photoURL\":\"\", \"reviews\":[{\"direction\":1, \"comment\": \"yo this thing was great\",\"creator\":\"andy\", \"dateCreated\":\"oct 11, 2010 4:39:42 AM\"},{\"direction\":-1, \"comment\": \"it was bad\",\"creator\":\"Steven\", \"dateCreated\":\"oct 12, 2010 4:39:42 AM\"}]}"; 
	NSLog(@"dishdetail text is %@", responseText);
	SBJSON *parser = [SBJSON new];
	NSError *error;
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText error:&error];
	[parser release];
	NSLog(@"the comment passed in object %@", [responseAsDictionary objectForKey:@"reviews"]);
	if(reviews == nil){
		NSLog(@"allocate the array the first time");
		reviews = [NSArray alloc];
	}
	reviews = [[responseAsDictionary objectForKey:@"reviews"] copy];
	
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
	NSArray *items = [self.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];	
	
	[responseText release];
	[_responseText release];
	_responseText = nil;
	[self.tableView reloadData];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"%@", error);
	
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
	else{
		[_responseText appendData:data];
	}
	//Add the data that came in to the data we have so far
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

