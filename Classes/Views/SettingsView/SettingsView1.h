//
//  SettingsView1.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsView1 : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
	int *pointer;
	int pickerSelected;
	NSArray *mPickerArray;
	
	UIPickerView *mPickerView;
	UIView	*mPickerViewOverlay;
	UIButton *mPickerViewButton;
	
	BOOL mPickerUp;
	
	UIView *mFooterView;
}


@property (nonatomic, retain) NSArray *pickerArray;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *pickerViewOverlay;
@property (nonatomic, retain) IBOutlet UIButton *pickerViewButton;

@property (nonatomic, retain) IBOutlet UIView *footerView;
-(IBAction) pickerDone;
-(IBAction) filtersDoneButtonPressed;
@end

