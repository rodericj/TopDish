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
//#import "SignInSignUpViewController.h"
#import "AppModel.h"
#import "TopDishAppDelegate.h"

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
	//[self.scrollView setContentSize:CGSizeMake(IPHONESCREENWIDTH, IPHONESCREENHEIGHT+200 )];
	currentVote = 0;

}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[AppModel instance].user objectForKey:keyforauthorizing] == nil)
		[[(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:kAccountsTab];
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
	NSLog(@"the dish id is %@", [self.dish dish_id]);
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/rateDish"]];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.dishComment.text forKey:@"comment"];
	[request setPostValue:[NSNumber numberWithInt:currentVote] forKey:@"direction"];
	[request setPostValue:[NSString stringWithFormat:@"%@", [self.dish dish_id]] forKey:@"dishId"];		
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	//NSLog(@"key %@, value %@", keyforauthorizing, [[AppModel instance] user] objectForKey:keyforauthorizing]);
	NSLog(@"request is %@", request);
	NSLog(@"this is what we are sending for RATE a dish: url: %@\n, comment: %@\n, vote: %d\n, dish_id %@\n, apiKey: %@", 
		  [url absoluteURL], 
		  self.dishComment.text, 
		  currentVote, 
		  [self.dish dish_id],
		  [[[AppModel instance] user] objectForKey:keyforauthorizing]); 

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
	//NSData *responseData = [request responseData];
	NSString *responseText = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];

	NSLog(@"response string %@  \nand of course %@", responseString, responseText);
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
