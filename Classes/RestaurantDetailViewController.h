//
//  RestaurantDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"
#import "BaseDishTableViewer.h"

@interface RestaurantDetailViewController : BaseDishTableViewer {
	Restaurant *restaurant;
	
	UITableViewCell *mRestaurantHeader;
	UILabel *mRestaurantName;
	UILabel *mRestaurantAddress;
	UIButton *mRestaurantPhone;
	UIImageView *mRestaurantImage;
}

@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) IBOutlet UITableViewCell *restaurantHeader;
@property (nonatomic, retain) IBOutlet UILabel *restaurantName;
@property (nonatomic, retain) IBOutlet UILabel *restaurantAddress;
@property (nonatomic, retain) IBOutlet UIButton *restaurantPhone;
@property (nonatomic, retain) IBOutlet UIImageView *restaurantImage;
-(IBAction)callRestaurant;

@end
