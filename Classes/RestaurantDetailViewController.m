//
//  RestaurantDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "constants.h"
#import "JSON.h"
#import "asyncimageview.h"
#import "AddADishViewController.h"
#import "ImagePickerViewController.h"

#define kRestaurantHeaderSection 0
#define kMapSection 2
#define kDishesAtThisRestaurantSection 1

@implementation RestaurantDetailViewController
@synthesize restaurant;
@synthesize restaurantHeader = mRestaurantHeader;
@synthesize mapRow = mMapRow;
@synthesize restaurantName = mRestaurantName;
@synthesize restaurantAddress = mRestaurantAddress;
@synthesize restaurantPhone = mRestaurantPhone;
@synthesize restaurantImage = mRestaurantImage;
@synthesize mapView = mMapView;

#pragma mark -
#pragma mark networking

-(void)processIncomingNetworkText:(NSString *)responseText{
	NSLog(@"processing incoming network text %@", responseText);
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		NSLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		return;
	}
	
	NSDictionary *resp = [[responseAsDictionary objectForKey:@"restaurants"] objectAtIndex:0];
	[parser release];
	
	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"json error %@", error);
		NSLog(@"the text %@", responseText);
	}
	NSLog(@"the dict is %@", resp);
	//[restaurant setObjName:[resp objectForKey:@"name"]];
	[restaurant setCity:[resp objectForKey:@"city"]];
	[restaurant setAddressLine1:[resp objectForKey:@"addressLine1"]];
	[restaurant setAddressLine2:[resp objectForKey:@"addressLine2"]];
	[restaurant setLatitude:[resp objectForKey:@"latitude"]];
	[restaurant setLongitude:[resp objectForKey:@"longitude"]];
	[restaurant setPhone:[resp objectForKey:@"phone"]];
	[restaurant setState:[resp objectForKey:@"state"]];
	[self.tableView reloadData];
	
}

-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	[[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE] autorelease]; 
	
}

#pragma mark -
#pragma mark fetch handling
-(NSPredicate *)restaurantDetailFilter {
	return [NSPredicate predicateWithFormat: @"%K = %@", 
			@"restaurant.restaurant_id", [restaurant restaurant_id]];
}
-(void) populatePredicateArray:(NSMutableArray *)filterPredicateArray{
	//do nothing
}
#pragma mark -
#pragma mark View lifecycle
- (void) setUpSpecificView {
}
- (void)viewDidLoad {
    [super viewDidLoad];
	[self networkQuery:[NSString stringWithFormat:@"%@/api/restaurantDetail?id[]=%@", NETWORKHOST, [restaurant restaurant_id]]];
	self.view.backgroundColor = kTopDishBackground;
}

#pragma mark -
#pragma mark Table view classes overridden 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kRestaurantHeaderSection:
			return self.restaurantHeader.bounds.size.height;
			break;
		case kMapSection:
			return self.mapRow.bounds.size.height;
		default:
			return [super tableView:tableView heightForRowAtIndexPath:indexPath];
			break;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == kRestaurantHeaderSection || section == kMapSection) {
		return 1;
	}
	NSLog(@"sections is %@ and this sectin is ", self.fetchedResultsController.sections);
    id <NSFetchedResultsSectionInfo> sectionInfo = 
	[[self.fetchedResultsController sections] 
	 objectAtIndex:section-kDishesAtThisRestaurantSection];
	if (sectionInfo == nil){
		return 0;
	}
	//Add 1 for the "Add a new dish cell"
	return [sectionInfo numberOfObjects] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kRestaurantHeaderSection) {
		[self.restaurantName setText:[restaurant objName]];
		
		[self.restaurantPhone setTitle:[restaurant phone] 
							  forState:UIControlStateNormal];
		[self.restaurantAddress setText:[restaurant addressLine1]];
		if (self.restaurantImage) {
			
			AsyncImageView *asyncImage = [[AsyncImageView alloc] 
										  initWithFrame:[self.restaurantImage frame]];
			asyncImage.tag = 999;
			if( [[restaurant photoURL] length] > 0 ){
				NSRange aRange = [[restaurant photoURL] rangeOfString:@"http://"];
				NSString *prefix = @"";
				if (aRange.location ==NSNotFound)
					prefix = NETWORKHOST;
				//TODO, we are not getting dish height and width
				NSString *urlString = [NSString stringWithFormat:@"%@%@", 
									   prefix, 
									   [restaurant photoURL], 
									   DISHDETAILIMAGECELLHEIGHT,
									   DISHDETAILIMAGECELLHEIGHT];
			
				NSLog(@"url string for restaurant's image in RestaurantDetailViewController is %@", urlString);

				NSURL *photoUrl = [NSURL URLWithString:urlString];
				[asyncImage loadImageFromURL:photoUrl withImageView:self.restaurantImage 
									 isThumb:NO showActivityIndicator:FALSE];
				//[cell.contentView addSubview:asyncImage];
				[self.restaurantHeader addSubview:asyncImage];
			}
		}
		self.restaurantHeader.selectionStyle = UITableViewCellSelectionStyleNone;
		return self.restaurantHeader;
	}
	if (indexPath.section == kMapSection) {
		CLLocationCoordinate2D center;
		center.latitude = [[self.restaurant latitude] floatValue];
		center.longitude = [[self.restaurant longitude] floatValue];
		MKCoordinateRegion m;
		m.center = center;
		
		MKCoordinateSpan span;
		span.latitudeDelta = .003;
		span.longitudeDelta = .003;
		
		//Set up the span
		m.span = span;
		[self.mapView setRegion:m animated:YES];		
		return self.mapRow;
	}
	//Hack..since we added the entire section above the table for the header,
	//we need to grab all of the fetched results from section 0. 
	//Get it? just subtract one
	return [super tableView:tableView 
		dishCellAtIndexPath:[NSIndexPath
							 indexPathForRow:indexPath.row 
							 inSection:indexPath.section-kDishesAtThisRestaurantSection]];
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kRestaurantHeaderSection) {
		return;
	}
	if (indexPath.row == [[[self.fetchedResultsController sections] objectAtIndex:[indexPath section]-kDishesAtThisRestaurantSection] numberOfObjects]) {
		AddADishViewController *addDishViewController = [[AddADishViewController alloc] initWithNibName:@"AddADishViewController" bundle:nil];
		[addDishViewController setTitle:@"Add a Dish"];
		[addDishViewController setRestaurant:restaurant];
		[addDishViewController setManagedObjectContext:self.managedObjectContext];
		[self.navigationController pushViewController:addDishViewController animated:YES];
		[addDishViewController release];
		
	}	
	else
		[self pushDishViewController:[self.fetchedResultsController 
									  objectAtIndexPath:[NSIndexPath 
														 indexPathForRow:indexPath.row 
														 inSection:indexPath.section-kDishesAtThisRestaurantSection]]];
}


-(IBAction)callRestaurant{
	
	NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@", [restaurant phone]];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSURL *url = [NSURL URLWithString:phoneNumber];
	
	[ [UIApplication sharedApplication] openURL:url];
	
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
	self.restaurant = nil;
	self.restaurantHeader = nil;
	self.restaurantName = nil;
	self.restaurantAddress = nil;
	self.restaurantPhone = nil;
	self.restaurantImage = nil;
	
	self.mapRow = nil;
	self.mapView = nil;
	
    [super dealloc];
}


@end

