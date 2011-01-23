//
//  DishOptionPickerTableViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DishOptionPickerTableViewController : UITableViewController {
	NSArray *mOptionValues;
	int mOptionType;
}

@property (nonatomic, assign) int optionType;
@property (nonatomic, retain) NSArray *optionValues;
@end
