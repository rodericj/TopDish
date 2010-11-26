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

@implementation RestaurantDetailViewController
@synthesize restaurant;

#pragma mark -
#pragma mark networking

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSLog(@"connection did finish loading");
	NSString *responseText = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
	NSLog(@"response text before replacing %@", responseText);
	
	
	responseText = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	NSLog(@"response text after replacing %@", responseText);
	[self processIncomingNetworkText:responseText];
}

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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(_responseData == nil){
		_responseData= [[NSMutableData alloc] initWithData:data];
	}
	else{
		if (data) {
			[_responseData appendData:data];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"connection did fail with error %@", error);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode

	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];
#else	
	//Airplane mode must set _responseText
	[self processIncomingNetworkText:RestaurantResponseText];

#endif
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
	[restaurantName setText:[restaurant restaurant_name]];
	[restaurantPhone setText:[restaurant phone]];
	[restaurantAddress setText:[restaurant addressLine1]];
	 
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

