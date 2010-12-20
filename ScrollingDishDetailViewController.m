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


@implementation ScrollingDishDetailViewController
@synthesize dish;
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
	[dishName setText:[dish objName]];
	[upVotes setText:[NSString stringWithFormat:@"%@", [dish posReviews]]];
	[downVotes setText:[NSString stringWithFormat:@"%@", [dish negReviews]]];
	
	[restaurantName setText:[[dish restaurant] objName]];
	
	//Set up description UILabel
	[description setNumberOfLines:0];
	[description setText:[NSString stringWithFormat:@"\"%@\"", [dish dish_description]]];
	[description sizeToFit];
	[description setLineBreakMode:UILineBreakModeWordWrap];
	[description setTextAlignment:UITextAlignmentCenter];
	
	if( [[dish photoURL] length] > 0 ){
		
		NSString *urlString = [NSString stringWithFormat:@"%@", [dish photoURL]]; 
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
		[asyncImage setOwningObject:dish];
		[asyncImage loadImageFromURL:photoUrl withImageView:dishImage isThumb:NO showActivityIndicator:FALSE];
	}
	
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
}

-(IBAction) pushRateViewController{
	RateDishViewController *rateDish = [[RateDishViewController alloc] init];
	[rateDish setDish:dish];
	[self.navigationController pushViewController:rateDish animated:YES];
	[rateDish release];
}

-(IBAction) goToRestaurantDetailView{
	NSLog(@"goToRestaurantDetailView");
	Restaurant *selectedObject = [dish restaurant];
	RestaurantDetailViewController *detailViewController = [[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" bundle:nil];
	[detailViewController setRestaurant:selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController setTitle:[selectedObject objName]];
	[detailViewController release];
}
@end
