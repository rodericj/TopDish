//
//  SettingsView1.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsView1 : UITableViewController {
	UISegmentedControl *mSegmentedControl;
	UITableViewCell *mSegmentedControlCell;
	UITableViewCell *mPriceSliderCell;
	UISlider *mPriceSlider;
	UITableViewCell *mPriceValueCell;
	UILabel *mPriceValue;
	UITableViewCell *mMealTypeCell;
	UILabel *mMealTypeLabel;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UITableViewCell *segmentedControlCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *priceSliderCell;
@property (nonatomic, retain) IBOutlet UISlider *priceSlider;
@property (nonatomic, retain) IBOutlet UITableViewCell *priceValueCell;
@property (nonatomic, retain) IBOutlet UILabel *priceValue;
@property (nonatomic, retain) IBOutlet UITableViewCell *mealTypeCell;
@property (nonatomic, retain) IBOutlet UILabel *mealTypeLabel;

-(IBAction) changeSegmentedSelector;

-(IBAction) updatePriceTags;

@end

