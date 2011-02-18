//
//  SettingsView1.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsView1 : UITableViewController {
	UITableViewCell *mPriceSliderCell;
	UISlider *mPriceSlider;
	UITableViewCell *mPriceValueCell;
	UILabel *mPriceValue;
	UITableViewCell *mMealTypeCell;
	UITableViewCell *mAllergenCell;
	UITableViewCell *mLifestyleCell;
	int *pointer;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *priceSliderCell;
@property (nonatomic, retain) IBOutlet UISlider *priceSlider;
@property (nonatomic, retain) IBOutlet UITableViewCell *priceValueCell;
@property (nonatomic, retain) IBOutlet UILabel *priceValue;
@property (nonatomic, retain) IBOutlet UITableViewCell *mealTypeCell;
-(IBAction) updatePriceTags;

@end

