//
//  DishDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"
#import "RateADishViewController.h"
#import "LoginModalView.h"

@interface DishDetailViewController : UIViewController <UINavigationControllerDelegate, 
UIImagePickerControllerDelegate, 
UIActionSheetDelegate,
RateDishProtocolDelegate,
LoginModalViewDelegate>{
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

	UITableViewCell *mTvCell;
	
	UIButton *mMoreButton;
	
	UIImage *mNewPicture;
	
	UITableView *mTableView;
	
	UIView *mInteractionOverlay;
	
	SEL mPostLoginAction;
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

@property (nonatomic, retain) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) IBOutlet UIButton *moreButton;

@property (nonatomic, retain) UIImage *newPicture;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *interactionOverlay;

-(IBAction)pushRateDishController;
-(IBAction)tapRestaurantButton;
-(IBAction)flagThisDish;
-(IBAction)takePicture;

-(void)pushRestaurantDetailController;

@end
