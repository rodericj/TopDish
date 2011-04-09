//
//  ThirdPartyRestaurantTableViewController.h
//  TopDish
//
//  Created by roderic campbell on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThirdPartyRestaurantsListDelegate

@required
-(void)restaurantSelected;

@end

@interface ThirdPartyRestaurantTableViewController : UITableViewController {
	NSArray *mRestaurants;
	id<ThirdPartyRestaurantsListDelegate> mDelegate;
}

@property (nonatomic, retain) NSArray *restaurants;
@property (nonatomic, assign) id<ThirdPartyRestaurantsListDelegate> delegate;

+(ThirdPartyRestaurantTableViewController *) viewControllerWithDelegate:(id)delegate;

@end
