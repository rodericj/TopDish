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
	IBOutlet UISlider *maxSlider;
	IBOutlet UISlider *minSlider;
	IBOutlet UILabel *maxLabel;
	IBOutlet UILabel *minLabel;
	IBOutlet UISegmentedControl *sortBySegmentedControl;
	DishTableViewController *delegate;
}

-(IBAction) cancelSettings;
-(IBAction) closeSettings; 
-(IBAction) updateMaxSlider;
-(IBAction) updateMinSlider;
-(void) updateSymbols;

@property (nonatomic, retain) DishTableViewController *delegate;
@property (nonatomic, retain) UIButton *refineButton;
@property (nonatomic, retain) UISlider *maxSlider;
@property (nonatomic, retain) UISlider *minSlider;
@property (nonatomic, retain) UILabel *maxLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UISegmentedControl *sortBySegmentedControl;

@end
