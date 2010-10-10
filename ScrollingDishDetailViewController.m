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

- (void)viewDidLoad {
    [super viewDidLoad];
	[scrollView
	 setContentSize:CGSizeMake(320, 9000)];
}
- (void)viewWillAppear:(BOOL)animated {
	
	
	NSLog(@"the dish %@", [dish dish_name]);
	[dishName setText:[dish dish_name]];
	[upVotes setText:[NSString stringWithFormat:@"%@", [dish posReviews]]];
	[downVotes setText:[NSString stringWithFormat:@"%@", [dish negReviews]]];
	
	NSURL *photoUrl = [NSURL URLWithString:[dish dish_photoURL]];

	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
	//NSData *photoData = [NSData dataWithContentsOfURL:photoUrl];
	[asyncImage loadImageFromURL:photoUrl withImageView:dishImage];
	
	//TODO Very bad, need to thread this. The issue is that it's not going to khttphost
	//[dishImage setImage:[UIImage imageWithData:photoData]];
    [super viewWillAppear:animated];
}

@end
