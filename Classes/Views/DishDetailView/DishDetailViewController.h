//
//  DishDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface DishDetailViewController : UITableViewController <UINavigationControllerDelegate, 
UIImagePickerControllerDelegate, 
UIActionSheetDelegate>{
	Dish *mThisDish;
	UITableViewCell *mDishImageCell;
	UIImageView *mDishImageView;
	UILabel *mNegativeReviews;
	UILabel *mPositiveReviews;	
	
	UITableViewCell *mDishDescriptionCell;
	UILabel	*mDishDescriptionLabel;
	
	UILabel *mDishTagsLabel;
	
	UILabel *mDishNameLabel;
	UILabel *mRestaurantNameLabel;
	
	NSArray *mReviews;
	NSData *mResponseData;

	NSManagedObjectContext *managedObjectContext_;
	UITableViewCell *mTvCell;
	
	UIButton *mMoreButton;
	
	UIImage *mNewPicture;
}

@property (nonatomic, retain) Dish *thisDish;
@property (nonatomic, retain) IBOutlet UITableViewCell *dishImageCell;
@property (nonatomic, retain) IBOutlet UIImageView *dishImageView;
@property (nonatomic, retain) IBOutlet UILabel *negativeReviews;
@property (nonatomic, retain) IBOutlet UILabel *positiveReviews;

@property (nonatomic, retain) IBOutlet UITableViewCell *dishDescriptionCell;
@property (nonatomic, retain) IBOutlet UILabel *dishDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *dishTagsLabel;

@property (nonatomic, retain) IBOutlet UILabel *dishNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;

@property (nonatomic, retain) NSArray *reviews;
@property (nonatomic, retain) NSData *responseData;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) IBOutlet UIButton *moreButton;

@property (nonatomic, retain) UIImage *newPicture;

-(IBAction)pushRateDishController;
-(IBAction)tapRestaurantButton;
-(IBAction)flagThisDish;
-(IBAction)takePicture;

-(void)pushRestaurantDetailController;

@end
