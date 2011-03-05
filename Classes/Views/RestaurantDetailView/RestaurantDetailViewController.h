//
//  RestaurantDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"
#import "DishTableViewController.h"
#import <MapKit/MapKit.h>

@interface RestaurantDetailViewController : DishTableViewController {
	Restaurant *restaurant;

	UITableViewCell *mMapRow;
	MKMapView *mMapView;

	UITableViewCell *mRestaurantHeader;
	UILabel *mRestaurantName;
	UILabel *mRestaurantAddress;
	UIButton *mRestaurantPhone;
	UIImageView *mRestaurantImage;
	UIView *mMapOverlay;
	
	UIButton *mMapButton;
	BOOL mMapShowing;
}

@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) IBOutlet UITableViewCell *restaurantHeader;
@property (nonatomic, retain) IBOutlet UILabel *restaurantName;
@property (nonatomic, retain) IBOutlet UILabel *restaurantAddress;
@property (nonatomic, retain) IBOutlet UIButton *restaurantPhone;
@property (nonatomic, retain) IBOutlet UIImageView *restaurantImage;

@property (nonatomic, retain) IBOutlet UITableViewCell *mapRow;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *mapOverlay;
@property (nonatomic, retain) UIButton *mapButton;

-(IBAction)callRestaurant;

@end
