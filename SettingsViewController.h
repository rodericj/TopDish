//
//  SettingsViewController.h
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DishTableViewController.h"

@interface SettingsView : UIViewController {
	UISlider *mMealTypeSlider;
	UISlider *mPriceSlider;
	UILabel *mMealTypeLabel;
	UILabel *mPriceLabel;
	UISegmentedControl *sortBySegmentedControl;
	DishTableViewController *delegate;
}

-(IBAction) cancelSettings;
-(IBAction) closeSettings; 
-(IBAction) updateMealType;
-(IBAction) updatePriceTags;
-(void) updateSymbols;

@property (nonatomic, retain) DishTableViewController *delegate;
@property (nonatomic, retain) IBOutlet UIButton *refineButton;
@property (nonatomic, retain) IBOutlet UISlider *mealTypeSlider;
@property (nonatomic, retain) IBOutlet UISlider *priceSlider;
@property (nonatomic, retain) IBOutlet UILabel *mealTypeLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) UISegmentedControl *sortBySegmentedControl;

@end
