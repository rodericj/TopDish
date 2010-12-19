//
//  RateDishViewController.h
//  TopDish
//
//  Created by roderic campbell on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface RateDishViewController : UIViewController {
	Dish *mDish;
	UILabel *mRestaurantName;
	UILabel *mDishName;
	UIView *mCurrentSelectionUp;
	UIView *mCurrentSelectionDown;
	UITextView *mDishDescription;
	UITextView *mDishComment;
	UIScrollView *mScrollView;
	UIImageView *mDishImage;
	int currentVote;

}
@property (nonatomic, retain) IBOutlet UITextView *dishDescription;
@property (nonatomic, retain) IBOutlet UITextView *dishComment;
@property (nonatomic, retain) IBOutlet UIView *currentSelectionUp;
@property (nonatomic, retain) IBOutlet UIView *currentSelectionDown;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) Dish *dish;
@property (nonatomic, retain) IBOutlet UILabel *restaurantName;
@property (nonatomic, retain) IBOutlet UILabel *dishName;
@property (nonatomic, retain) IBOutlet UIImageView *dishImage;

-(IBAction)voteUp;
-(IBAction)voteDown;
-(IBAction)closeKeyboard;
-(IBAction)submitRating;

@end
