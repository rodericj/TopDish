//
//  ScrollingDishDetailViewController.m
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScrollingDishDetailViewController.h"
#import "asyncimageview.h"

@implementation ScrollingDishDetailViewController
@synthesize dish;
@synthesize dishName;
@synthesize downVotes;
@synthesize upVotes;
@synthesize scrollView;
@synthesize dishImage;
@synthesize description;

- (void)viewDidLoad {
    [super viewDidLoad];
	[scrollView
	 setContentSize:CGSizeMake(320, 9000)];
}
- (void)viewWillAppear:(BOOL)animated {
	
	[dishName setText:[dish dish_name]];
	[upVotes setText:[NSString stringWithFormat:@"%@", [dish posReviews]]];
	[downVotes setText:[NSString stringWithFormat:@"%@", [dish negReviews]]];
	[description setText:[NSString stringWithFormat:@"\"%@\"", [dish dish_description]]];

	NSURL *photoUrl = [NSURL URLWithString:[dish dish_photoURL]];

	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
	[asyncImage loadImageFromURL:photoUrl withImageView:dishImage showActivityIndicator:FALSE];
	
	[super viewWillAppear:animated];
}

@end
