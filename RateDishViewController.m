//
//  RateDishViewController.m
//  TopDish
//
//  Created by roderic campbell on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RateDishViewController.h"
#import "constants.h"
#import "DishComment.h"

@implementation RateDishViewController

@synthesize restaurantName = mRestaurantName;
@synthesize dishName = mDishName;
@synthesize dish = mDish;
@synthesize scrollView = mScrollView;
@synthesize currentSelectionUp = mCurrentSelectionUp;
@synthesize currentSelectionDown = mCurrentSelectionDown;
@synthesize dishDescription = mDishDescription;
@synthesize dishComment = mDishComment;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"rate dish loaded");
	self.dishName.text = [self.dish objName];
	self.restaurantName.text = [[self.dish restaurant] objName];
	self.dishDescription.text = [self.dish dish_description];
	[self.scrollView setContentSize:CGSizeMake(IPHONESCREENWIDTH, IPHONESCREENHEIGHT )];
	currentVote = 0;

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

-(IBAction)voteUp{
	NSLog(@"voted up");
	currentVote = 1;
	[self.currentSelectionUp setBackgroundColor:[UIColor greenColor]];
	[self.currentSelectionDown setBackgroundColor:[UIColor grayColor]];
	
	
}
-(IBAction)voteDown{
	NSLog(@"voted down");
	currentVote = -1;
	[self.currentSelectionUp setBackgroundColor:[UIColor grayColor]];
	[self.currentSelectionDown setBackgroundColor:[UIColor redColor]];
}

-(IBAction)closeKeyboard{
	[self.dishDescription resignFirstResponder];
	[self.dishComment resignFirstResponder];
}

-(IBAction)submitRating{
	NSLog(@"submit rating");	
	NSLog(@"description %@ and %@ %d", self.dishDescription.text, self.dishComment.text, currentVote);
	
	DishComment *comment = [[DishComment alloc] init];
	[comment setDish:self.dish];
	[comment setComment:self.dishComment.text];
	[comment setIsPositive:[NSNumber numberWithInt:currentVote]];
	[comment setReviewer_id:[NSNumber numberWithInt:1]];
	[comment setReviewer_name:@"TODO GET A REVIEWER NAME"];
	NSLog(@"dish %@\ncomment %@");
}
- (void)dealloc {
    [super dealloc];
}


@end
