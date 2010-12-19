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
	IBOutlet UILabel *mRestaurantName;
	IBOutlet UILabel *mDishName;
	IBOutlet UIView *mCurrentSelectionUp;
	IBOutlet UIView *mCurrentSelectionDown;
	IBOutlet UITextView *mDishDescription;
	IBOutlet UITextView *mDishComment;
	IBOutlet UIScrollView *mScrollView;
	int currentVote;

}
@property (nonatomic, retain) UITextView *dishDescription;
@property (nonatomic, retain) UITextView *dishComment;
@property (nonatomic, retain) UIView *currentSelectionUp;
@property (nonatomic, retain) UIView *currentSelectionDown;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) Dish *dish;
@property (nonatomic, retain) UILabel *restaurantName;
@property (nonatomic, retain) UILabel *dishName;

-(IBAction)voteUp;
-(IBAction)voteDown;
-(IBAction)closeKeyboard;
-(IBAction)submitRating;

@end
