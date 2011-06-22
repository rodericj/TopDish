//
//  SettingsView1.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewDelegate

@required
-(void)didModifySettings;

@end


@interface SettingsView1 : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
	int *pointer;
	int pickerSelected;
	NSArray *mPickerArray;
	
	UIPickerView *mPickerView;
	UIView	*mPickerViewOverlay;
	UIButton *mPickerViewButton;
	
	BOOL mPickerUp;
	
	UIView *mFooterView;
	
	id <SettingsViewDelegate> mDelegate;
}


@property (nonatomic, retain) NSArray *pickerArray;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) IBOutlet UIView *pickerViewOverlay;
@property (nonatomic, retain) IBOutlet UIButton *pickerViewButton;

@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, assign) id<SettingsViewDelegate> delegate;

-(IBAction) pickerDone;
-(IBAction) filtersDoneButtonPressed;
@end

