//
//  AddADishViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface AddADishViewController : UITableViewController <UIImagePickerControllerDelegate> {
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

	UITableViewCell *mAdditionalDetailsCell;
	UITextView		*mAdditionalDetailsTextView;
	UIButton		*mSubmitButton;
	
	int mSelectedPriceType;
	int mSelectedMealType;
	int mCurrentSelection;
	
	int *pointer;

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

@property (nonatomic, retain) IBOutlet UITableViewCell *additionalDetailsCell;
@property (nonatomic, retain) IBOutlet UITextView *additionalDetailsTextView;
@property (nonatomic, retain) IBOutlet UIButton	*submitButton;

@property (nonatomic, assign) int selectedMealType;
@property (nonatomic, assign) int selectedPriceType;
@property (nonatomic, assign) int currentSelection;

-(IBAction)takePicture;
-(IBAction)submitDish;
-(IBAction)noButtonClicked;
-(IBAction)yesButtonClicked;

@end
