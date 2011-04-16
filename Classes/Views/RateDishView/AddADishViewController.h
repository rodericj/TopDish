//
//  AddADishViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@protocol AddADishProtocolDelegate

@required
-(void)addDishDone;

@end


@interface AddADishViewController : UITableViewController <UINavigationControllerDelegate, 
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UITextViewDelegate> {
	Restaurant *mRestaurant;
	
	UITableViewCell *mRestaurantCell;
	UILabel *mRestaurantTitle;
	
	UITableViewCell *mDishNameCell;
	UITextField *mDishTitle;
	
	UITableViewCell *mWouldYouCell;
	UIImageView *mYesImage;
	UIImageView *mNoImage;
	int mRating;
	
	UITableViewCell *mUploadCell;
	UIImageView *mNewPicture;
	
	UIView *mAdditionalDetailsCell;
	UITextView		*mAdditionalDetailsTextView;
	UITextView		*mCommentTextView;
	
	UIButton		*mSubmitButton;
	
	int mSelectedPriceType;
	int mSelectedMealType;
	int mCurrentSelection;
	
	int mDishId;
	
	//We need to handle all of the outstanding requests before leaving view
	int mOutstandingRequests;
	
	int pickerSelected;
	NSArray *mPickerArray;
	UIPickerView *mPickerView;
	UIView	*mPickerViewOverlay;
	UIButton *mPickerViewButton;
	BOOL mPickerUp;

	id<AddADishProtocolDelegate> mDelegate;
}

@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableViewCell *restaurantCell;
@property (nonatomic, retain) IBOutlet UILabel *restaurantTitle;

@property (nonatomic, retain) IBOutlet UITableViewCell *dishNameCell;
@property (nonatomic, retain) IBOutlet UITextField *dishTitle;

@property (nonatomic, retain) IBOutlet UITableViewCell *wouldYouCell;
@property (nonatomic, retain) IBOutlet UIImageView *noImage;
@property (nonatomic, retain) IBOutlet UIImageView *yesImage;
@property (nonatomic, assign) int rating;

@property (nonatomic, retain) IBOutlet UITableViewCell *uploadCell;
@property (nonatomic, retain) IBOutlet UIImageView *newPicture;

@property (nonatomic, retain) IBOutlet UIView *additionalDetailsCell;
@property (nonatomic, retain) UITextView *additionalDetailsTextView;
@property (nonatomic, retain) UITextView *commentTextView;
@property (nonatomic, retain) IBOutlet UIButton	*submitButton;

@property (nonatomic, assign) int selectedMealType;
@property (nonatomic, assign) int selectedPriceType;
@property (nonatomic, assign) int currentSelection;

@property (nonatomic, assign) int dishId;

@property (nonatomic, retain) NSArray *pickerArray;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *pickerViewOverlay;
@property (nonatomic, retain) IBOutlet UIButton *pickerViewButton;

@property (nonatomic, assign) id<AddADishProtocolDelegate> delegate;
-(IBAction)takePicture;
-(IBAction)submitDish;
-(IBAction)noButtonClicked;
-(IBAction)yesButtonClicked;
-(IBAction) pickerDone;

@end
