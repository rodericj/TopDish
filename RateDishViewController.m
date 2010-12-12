//
//  RateDishViewController.m
//  TopDish
//
//  Created by roderic campbell on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RateDishViewController.h"
#import "constants.h"

@implementation RateDishViewController

@synthesize restaurantName = mRestaurantName;
@synthesize dishName = mDishName;
@synthesize dish = mDish;
@synthesize scrollView = mScrollView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"rate dish loaded");
	self.dishName.text = [self.dish objName];
	self.restaurantName.text = [[self.dish restaurant] objName];
	[self.scrollView setContentSize:CGSizeMake(IPHONESCREENWIDTH, IPHONESCREENHEIGHT )];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
