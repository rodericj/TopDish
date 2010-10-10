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

@implementation ScrollingDishDetailViewController
@synthesize dish;
@synthesize dishName;
@synthesize downVotes;
@synthesize upVotes;
@synthesize scrollView;
@synthesize dishImage;
@synthesize description;

-(void)initializeDishDatabase{
	NSString *jsonData = @"[\
	{\
	\"id\":1,\
	\"dish_id\":\"2\",\
	\"reviewer_id\":\"2\",\
	\"comment\":\"I found that the beef was undercooked\",\
	\"reviewer_name\":\"Sunil Subhedar\",\
	\"restaurantID\":37,\
	},\
	{\
	\"id\":2,\
	\"dish_id\":\"2\",\
	\"reviewer_id\":\"3\",\
	\"comment\":\"Probably the best burger I've ever eaten\",\
	\"reviewer_name\":\"Salil Pandit\",\
	\"restaurantID\":37,\
	}]\
	";	
	
	SBJSON *parser = [SBJSON new];
	NSArray *responseAsArray = [parser objectWithString:jsonData error:NULL];
	[parser release];
	
	for (int i =0; i < [responseAsArray count]; i++){
		DishComment *thisDishComment = (DishComment *)[NSEntityDescription insertNewObjectForEntityForName:@"DishComment" inManagedObjectContext:self.managedObjectContext];
		NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
		//Need to query for a specific dish here
		
		
		//[thisDishComment setDish_id:<#(Dish *)#>:[thisElement objectForKey:@"dish_id"]];
		
		[thisDishComment setReviewer_name:[thisElement objectForKey:@"reviewer_name"]];
		[thisDishComment setComment:[thisElement objectForKey:@"comment"]];
		
		}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DishComment"  
											  inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *items = [self.managedObjectContext
					  executeFetchRequest:fetchRequest error:&error];
	NSLog(@"items is %@", items);
	[fetchRequest release];	
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[scrollView setContentSize:CGSizeMake(320, 9000)];
	//[self initializeDishDatabase];

}
- (void)viewWillAppear:(BOOL)animated {
	
	[dishName setText:[dish dish_name]];
	[upVotes setText:[NSString stringWithFormat:@"%@", [dish posReviews]]];
	[downVotes setText:[NSString stringWithFormat:@"%@", [dish negReviews]]];
	
	//Set up description UILabel
	[description setNumberOfLines:0];
	[description setText:[NSString stringWithFormat:@"\"%@\"", [dish dish_description]]];
	[description sizeToFit];
	[description setLineBreakMode:UILineBreakModeWordWrap];
	[description setTextAlignment:UITextAlignmentCenter];

	CGAffineTransform translate = CGAffineTransformMakeTranslation(0,[description frame].size.height);
	commentSubView
	.transform = translate;
	
	NSLog(@"the length of this description %d", [[dish dish_description] length]);
	NSURL *photoUrl = [NSURL URLWithString:[dish dish_photoURL]];

	AsyncImageView *asyncImage = [[AsyncImageView alloc] initWithFrame:[dishImage frame]];
	[asyncImage loadImageFromURL:photoUrl withImageView:dishImage showActivityIndicator:FALSE];
	
	[super viewWillAppear:animated];
}

@end
