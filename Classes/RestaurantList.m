//
//  RestaurantList.m
//  TopDish
//
//  Created by roderic campbell on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestaurantList.h"
#import "constants.h"

@implementation RestaurantList

@synthesize returnView = mReturnView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dishes", @"Restaurants", nil]];
	[s setSegmentedControlStyle:UISegmentedControlStyleBar];
	[s addTarget:self action:@selector(changeToDishes)
					forControlEvents:UIControlEventValueChanged];	
	self.navigationItem.titleView = s;
	self.navigationController.navigationBar.tintColor = kTopDishBlue;

	//[s release];
}
-(void)viewWillAppear:(BOOL)animated {
	UISegmentedControl *s = (UISegmentedControl *) self.navigationItem.titleView;
	[s setSelectedSegmentIndex:1];
}

-(void)changeToDishes {
	NSLog(@"change to dishes");
	NSMutableArray *views = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
	[views replaceObjectAtIndex:0 withObject:self.returnView];
	[self.navigationController setViewControllers:views animated:NO];
}

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
