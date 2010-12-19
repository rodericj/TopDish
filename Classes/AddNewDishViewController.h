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
}

@property (nonatomic, retain) Dish *dish;
@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) IBOutlet UITextField *dishNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *dishImageFromPicker;

-(IBAction)addDish;
@end
