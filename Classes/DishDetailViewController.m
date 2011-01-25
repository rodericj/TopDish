//
//  DishDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DishDetailViewController.h"
#import "asyncimageview.h"
#import "constants.h"
#import "JSON.h"
#import "RateDishViewController.h"

#define kImageSection 0
#define kDescriptionSection 1
#define kCommentsSection 2

@implementation DishDetailViewController

@synthesize thisDish = mThisDish;
@synthesize dishImageCell = mDishImageCell;
@synthesize dishImageView = mDishImageView;
@synthesize dishDescriptionCell = mDishDescriptionCell;
@synthesize dishDescriptionLabel = mDishDescriptionLabel;

@synthesize dishNameLabel = mDishNameLabel;
@synthesize restaurantNameLabel = mRestaurantNameLabel;

@synthesize reviews = mReviews;
@synthesize responseText = mResponseText;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == kDescriptionSection)
		return @"Description";
	if (section == kCommentsSection)
		return @"Comments";
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kImageSection:
			return 1;
			break;
		case kDescriptionSection:
			return 1;
			break;
		
		case kCommentsSection:
			return [self.reviews count];
		default:
			return 1;
			break;
	}
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	
	switch (indexPath.section) {
		case kImageSection:
			cell = self.dishImageCell;
			break;
			
		case kDescriptionSection:
			cell = self.dishDescriptionCell;
			break;

		case kCommentsSection:
			cell = [tableView dequeueReusableCellWithIdentifier:@"DishDetailCommentCell"];
			if (!cell)
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DishDetailCommentCell"];

			NSString *comment = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"comment"];
			NSString *creator = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"creator"];
			NSString *combined = [NSString stringWithFormat:@"%@ -%@", comment, creator];
			[cell.textLabel setText:combined];
			[cell.textLabel setNumberOfLines:4];
			
		default:
			break;
	}
	// Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kImageSection) {
		//return 280;
		return self.dishImageCell.bounds.size.height;
	}
	if (indexPath.section == kDescriptionSection) {
		
		//self.dishDescriptionCell.frame = CGRectMake(c.origin.x, c.origin.y, c.size.width, c.size.height);
		//self.dishDescriptionCell.frame.size.height = [self.dishDescriptionLabel numberOfLines] * 25;
		return self.dishDescriptionCell.bounds.size.height;
	}
	return 100;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidLoad {
	NSLog(@"view did load for %@", [self.thisDish objName]);
	if( [[self.thisDish photoURL] length] > 0 ){
		
		NSString *urlString = [NSString stringWithFormat:@"%@&w=%d&h=%d", 
							   [self.thisDish photoURL], 
							   self.dishImageView.bounds.size.width, 
							   self.dishImageView.bounds.size.height]; 
		
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[self.dishImageView frame]];
		[asyncImage setOwningObject:self.thisDish];
		[asyncImage loadImageFromURL:photoUrl withImageView:self.dishImageView isThumb:NO showActivityIndicator:FALSE];
	}
	[self.dishDescriptionLabel setText:[self.thisDish dish_description]];
	[self.dishDescriptionLabel numberOfLines];
	
	[self.dishNameLabel setText:[self.thisDish objName]];
	[self.dishNameLabel setTextColor:kTopDishBlue];
	
	[self.restaurantNameLabel setText:[[self.thisDish restaurant] objName]];
	[self.restaurantNameLabel setTextColor:kTopDishBlue];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", NETWORKHOST, [self.thisDish dish_id]]];
	//Start up the networking
	NSLog(@"the comments url is %@", url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
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

-(IBAction)pushRateDishController {
	RateDishViewController *rateDish = [[RateDishViewController alloc] init];
	[rateDish setDish:self.thisDish];
	[self.navigationController pushViewController:rateDish animated:YES];
	
	[rateDish release];
	
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

