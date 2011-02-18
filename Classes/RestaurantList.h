//
//  RestaurantList.h
//  TopDish
//
//  Created by roderic campbell on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RestaurantList : UIViewController {
	UIViewController *mReturnView;
	UISegmentedControl *mSegmentedControl;
}

@property (nonatomic, retain) UIViewController *returnView;

-(void)changeToDishes;

@end
