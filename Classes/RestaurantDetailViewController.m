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

@implementation RestaurantDetailViewController
@synthesize restaurant;
//@synthesize _responseData;

#pragma mark -
#pragma mark networking



-(void)processIncomingNetworkText:(NSString *)responseText{
	NSLog(@"processing incoming network text %@", responseText);
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSDictionary *responseAsDict = [parser objectWithString:responseText error:&error];	
	[parser release];
	
	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"%@", error);
		NSLog(@"the text %@", responseText);
	}
	NSLog(@"the dict is %@", responseAsDict);
	
}



-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	conn = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE] autorelease]; 
	
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView setTableHeaderView:restaurantHeader];
	[self networkQuery:[NSString stringWithFormat:@"%@/api/RestaurantDetail?id[]=%@", NETWORKHOST, [restaurant restaurant_id]]];
	[restaurantName setText:[restaurant objName]];
	[restaurantPhone setText:[restaurant phone]];
	[restaurantAddress setText:[restaurant addressLine1]];
	 
	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[restaurantImage frame]];
	asyncImage.tag = 999;
	if( [[restaurant photoURL] length] > 0 ){
		NSString *urlString = [NSString stringWithFormat:@"%@&w=70&h=70", [restaurant photoURL]];
		NSLog(@"the url of the resto image %@", urlString);
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		[asyncImage loadImageFromURL:photoUrl withImageView:restaurantImage isThumb:NO showActivityIndicator:FALSE];
		//[cell.contentView addSubview:asyncImage];
		[restaurantHeader addSubview:asyncImage];
	}
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [super dealloc];
}


@end

