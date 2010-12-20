//
//  ScrollingDishDetailViewController.m
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollingDishDetailViewController.h"
#import "asyncimageview.h"
#import "JSON.h"
#import "constants.h"
#import "RestaurantDetailViewController.h"
#import "RateDishViewController.h"
#import "Restaurant.h"
#import "CommentsTableViewController.h"


@implementation ScrollingDishDetailViewController
@synthesize dish = mDish;
@synthesize dishName;
@synthesize downVotes;
@synthesize upVotes;
@synthesize scrollView;
@synthesize dishImage;
@synthesize description;
@synthesize restaurantName;

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;

- (void)viewDidLoad {
    [super viewDidLoad];
	[dishName setText:[self.dish objName]];
	[upVotes setText:[NSString stringWithFormat:@"%@", [self.dish posReviews]]];
	[downVotes setText:[NSString stringWithFormat:@"%@", [self.dish negReviews]]];
	
	[restaurantName setText:[[self.dish restaurant] objName]];
	
	//Set up description UILabel
	[description setNumberOfLines:0];
	[description setText:[NSString stringWithFormat:@"\"%@\"", [self.dish dish_description]]];
	[description sizeToFit];
	[description setLineBreakMode:UILineBreakModeWordWrap];
	[description setTextAlignment:UITextAlignmentCenter];
	
	if( [[self.dish photoURL] length] > 0 ){
		NSString *urlString = [NSString stringWithFormat:@"%@", [self.dish photoURL]]; 
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
		[asyncImage setOwningObject:self.dish];
		[asyncImage loadImageFromURL:photoUrl withImageView:dishImage isThumb:NO showActivityIndicator:FALSE];
	}	
}

-(IBAction)pushRestaurant{
	CommentsTableViewController *c = (CommentsTableViewController*)self.parentViewController;
	[c goToRestaurantDetailView];
	//RateDishViewController *rateDish = [[RateDishViewController alloc] init];
//	[rateDish setDish:self.dish];
//	[self.parentViewController pushViewController:rateDish animated:YES];
//	[rateDish release];
}
@end
