//
//  DishDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface DishDetailViewController : UITableViewController {
	Dish *mThisDish;
	UITableViewCell *mDishImageCell;
	UIImageView *mDishImageView;
	UILabel *mNegativeReviews;
	UILabel *mPositiveReviews;	
	
	UITableViewCell *mDishDescriptionCell;
	UILabel	*mDishDescriptionLabel;
	
	UILabel *mDishNameLabel;
	UILabel *mRestaurantNameLabel;
	
	NSArray *mReviews;
	NSData *mResponseText;

	NSManagedObjectContext *managedObjectContext_;

}

@property (nonatomic, retain) Dish *thisDish;
@property (nonatomic, retain) IBOutlet UITableViewCell *dishImageCell;
@property (nonatomic, retain) IBOutlet UIImageView *dishImageView;
@property (nonatomic, retain) IBOutlet UILabel *negativeReviews;
@property (nonatomic, retain) IBOutlet UILabel *positiveReviews;

@property (nonatomic, retain) IBOutlet UITableViewCell *dishDescriptionCell;
@property (nonatomic, retain) IBOutlet UILabel *dishDescriptionLabel;

@property (nonatomic, retain) IBOutlet UILabel *dishNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;

@property (nonatomic, retain) NSArray *reviews;
@property (nonatomic, retain) NSData *responseText;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction)pushRateDishController;
@end
