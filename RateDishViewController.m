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
#import "ASIFormDataRequest.h"

@implementation RateDishViewController

@synthesize restaurantName = mRestaurantName;
@synthesize dishName = mDishName;
@synthesize dish = mDish;
@synthesize scrollView = mScrollView;
@synthesize currentSelectionUp = mCurrentSelectionUp;
@synthesize currentSelectionDown = mCurrentSelectionDown;
@synthesize dishDescription = mDishDescription;
@synthesize dishComment = mDishComment;
@synthesize dishImage = mDishImage;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"rate dish loaded");
	self.dishName.text = [self.dish objName];
	self.restaurantName.text = [[self.dish restaurant] objName];
	self.dishDescription.text = [self.dish dish_description];
	NSLog(@"dish when the view loaded %@", self.dish);
	self.dishImage.image = [UIImage imageWithData:[self.dish imageData]];
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
	
	//Should probably create a Comment here, this will help with unsubmitted data
	//DishComment *comment = [[DishComment alloc] init];
//	//[comment setDish:self.dish];
//	[comment setComment:self.dishComment.text];
//	[comment setIsPositive:[NSNumber numberWithInt:currentVote]];
//	[comment setReviewer_id:[NSNumber numberWithInt:1]];
//	[comment setReviewer_name:@"TODO GET A REVIEWER NAME"];
	
	NSURL *url = [NSURL URLWithString: @"http://www.topdish.com/api/rateDish"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.dishComment.text forKey:@"comment"];
	[request setPostValue:[NSNumber numberWithInt:currentVote] forKey:@"isPositive"];
	[request setPostValue:[self.dish dish_id] forKey:@"dishid"];	
	[request setPostValue:@"TODO GET A REVIEWER NAME" forKey:@"reviewer_name"];	
	[request setPostValue:@"1" forKey:@"reviewer_id"];	
	
	// Upload an NSData instance
	//[request setData:imageData withFileName:@"myphoto.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
	[request setDelegate:self];
	[request startAsynchronous];

}
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	NSString *responseText = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];

	NSLog(@"response string %@ \n and data %@\n \nand of course %@", responseString, responseData, responseText);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"error %@", error);
}
- (void)dealloc {
    [super dealloc];
}


@end
