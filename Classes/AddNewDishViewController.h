//
//  AddNewDishViewController.h
//  TopDish
//
//  Created by roderic campbell on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface AddNewDishViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	Restaurant *mRestaurant;
	Dish *mDish;
	UITextField *mDishNameTextField;
	UILabel *mRestaurantNameLabel;
	UIImageView *mDishImageFromPicker;
	BOOL mHasPicture;
	int mDishId;
	UIButton *mMealTypePickerButton;
	UIButton *mPricePickerButton;
	UIPickerView *mPickerView;
	NSArray *mPickerArray;
	NSString *mSelectedPrice;
	NSString *mSelectedMealType;
	UILabel *mMealTypeLabel;
	UILabel *mPriceLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *mealTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;


@property (nonatomic, retain) NSString *selectedMealType;
@property (nonatomic, retain) NSString *selectedPrice;
@property (nonatomic, retain) NSArray *pickerArray;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIButton *mealTypePickerButton;
@property (nonatomic, retain) UIButton *pricePickerButton;
@property (nonatomic, assign) BOOL hasPicture;
@property (nonatomic, assign) int dishId;
@property (nonatomic, retain) Dish *dish;
@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) IBOutlet UITextField *dishNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *dishImageFromPicker;

-(IBAction)addDish;
-(IBAction)pickPrice;
-(IBAction)pickMealType;

@end
