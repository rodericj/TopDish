//
//  ScrollingDishDetailViewController.m
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollingDishDetailViewController.h"
#import "asyncimageview.h"
#import "JSON.h"
#import "DishComment.h"
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
@synthesize commentsController;
@synthesize commentSubView;
@synthesize restaurantName;

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;

- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"the height of the description %f", [description frame].size.height);
	NSLog(@"height of the comments %f", [commentSubView frame].size.height);
	float descriptionHeight = [description frame].size.height;
	float commentHeight = [commentSubView frame].size.height;

	float imageHeight = [dishImage frame].size.height;

	[scrollView setContentSize:CGSizeMake(320, descriptionHeight+commentHeight+imageHeight + 528)];

}

- (void)viewWillAppear:(BOOL)animated {
	
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

	CGAffineTransform translate = CGAffineTransformMakeTranslation(0,[description frame].size.height);
	commentSubView.transform = translate;
	
	if( [[dish photoURL] length] > 0 ){

		NSString *urlString = [NSString stringWithFormat:@"%@", [dish photoURL]]; 
		NSURL *photoUrl = [NSURL URLWithString:urlString];
		AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
		[asyncImage setOwningObject:dish];
		[asyncImage loadImageFromURL:photoUrl withImageView:dishImage isThumb:NO showActivityIndicator:FALSE];
	}
	[super viewWillAppear:animated];
	
	[commentsController setManagedObjectContext:self.managedObjectContext];
	[commentsController setDishId:[dish dish_id]];
	
	[commentsController refreshFromServer];
	
	float commentHeight = [commentsController.tableView contentSize].height;
	
	NSLog(@"determine comment height after viewWillAppear %f", commentHeight);
	//TODO Set the height of the UIScrollView here. We should know the height of all of the internal views. Should be able to set it.
	
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
