//
//  RateADishViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface RateADishViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	Dish *mThisDish;
	UITableViewCell *mDishHeaderCell;
	UILabel *mDishTitle;
	UILabel *mRestaurantTitle;
	UIImageView *mDishImage;
	
	UITableViewCell *mDishCommentCell;
	UITextView	*mDishComment;
	
	UITableViewCell *mWouldYouCell;
	UISwitch *mWouldYou;
	
	UITableViewCell *mPictureCell;
	UIImageView *mNewPicture;
	
	UITableViewCell *mSubmitButtonCell;
	UIButton		*mSubmitButton;
}

@property (nonatomic, retain) Dish *thisDish;
@property (nonatomic, retain) IBOutlet UITableViewCell *dishHeaderCell;
@property (nonatomic, retain) IBOutlet UILabel *dishTitle;
@property (nonatomic, retain) IBOutlet UILabel *restaurantTitle;
@property (nonatomic, retain) IBOutlet UIImageView *dishImage;

@property (nonatomic, retain) IBOutlet UITableViewCell *dishCommentCell;
@property (nonatomic, retain) IBOutlet UITextView *dishComment;

@property (nonatomic, retain) IBOutlet UITableViewCell *wouldYouCell;
@property (nonatomic, retain) IBOutlet UISwitch *wouldYou;

@property (nonatomic, retain) IBOutlet UITableViewCell *pictureCell;
@property (nonatomic, retain) IBOutlet UIImageView *newPicture;

@property (nonatomic, retain) IBOutlet UITableViewCell *submitButtonCell;
@property (nonatomic, retain) IBOutlet UIButton	*submitButton;

-(IBAction)takePicture;
-(IBAction)submitRating;
@end
