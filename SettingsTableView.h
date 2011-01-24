//
//  SettingsTableView.h
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsTableView : UITableViewController {
	UISegmentedControl *mSegmentedControl;
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@end
