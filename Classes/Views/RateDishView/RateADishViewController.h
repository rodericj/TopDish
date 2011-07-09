//
//  RateADishViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"
#import "MBProgressHUD.h"
#import "ASIProgressDelegate.h"

@protocol RateDishProtocolDelegate
@required
-(void)doneRatingDish;

@end

@interface RateADishViewController : UITableViewController <UIImagePickerControllerDelegate, 
UINavigationControllerDelegate,
UIActionSheetDelegate,
ASIProgressDelegate,
MBProgressHUDDelegate>{
	Dish *mThisDish;
	UITableViewCell *mDishHeaderCell;
	UILabel *mDishTitle;
	UILabel *mRestaurantTitle;
	UIImageView *mDishImage;
	UILabel *mPositiveReviews;
	UILabel *mNegativeReviews;
	
	UITableViewCell *mDishCommentCell;
	UITextView	*mDishComment;
	
	UITableViewCell *mWouldYouCell;
	UIImageView *mYesImage;
	UIImageView *mNoImage;
	int mRating;
	
	UITableViewCell *mPictureCell;
	UIImageView *mNewPicture;
	
	UITableViewCell *mSubmitButtonCell;
	UIButton		*mSubmitButton;
	int mOutstandingRequests;
	
	id<RateDishProtocolDelegate> mDelegate;
	
	MBProgressHUD *mHUD;
	BOOL mUploadSuccess;

	
}

@property (nonatomic, retain) Dish *thisDish;
@property (nonatomic, retain) IBOutlet UITableViewCell *dishHeaderCell;
@property (nonatomic, retain) IBOutlet UILabel *dishTitle;
@property (nonatomic, retain) IBOutlet UILabel *restaurantTitle;
@property (nonatomic, retain) IBOutlet UIImageView *dishImage;
@property (nonatomic, retain) IBOutlet UILabel *positiveReviews;
@property (nonatomic, retain) IBOutlet UILabel *negativeReviews;

@property (nonatomic, retain) IBOutlet UITableViewCell *dishCommentCell;
@property (nonatomic, retain) IBOutlet UITextView *dishComment;

@property (nonatomic, retain) IBOutlet UITableViewCell *wouldYouCell;
@property (nonatomic, retain) IBOutlet UIImageView *noImage;
@property (nonatomic, retain) IBOutlet UIImageView *yesImage;
@property (nonatomic, assign) int rating;

@property (nonatomic, retain) IBOutlet UITableViewCell *pictureCell;
@property (nonatomic, retain) IBOutlet UIImageView *newPicture;

@property (nonatomic, retain) IBOutlet UITableViewCell *submitButtonCell;
@property (nonatomic, retain) IBOutlet UIButton	*submitButton;

@property (nonatomic, assign)  id<RateDishProtocolDelegate>	delegate;

-(IBAction)takePicture;
-(IBAction)submitRating;
-(IBAction)noButtonClicked;
-(IBAction)yesButtonClicked;

	
@end
