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
#import "AddADishViewController.h"
#import "IncomingProcessor.h"
#import "LoginModalView.h"

@interface RestaurantDetailViewController : DishTableViewController 
<UIActionSheetDelegate, 
UINavigationControllerDelegate, 
UIImagePickerControllerDelegate,
AddADishProtocolDelegate,
IncomingProcessorDelegate,
LoginModalViewDelegate> {
	
	Restaurant			*restaurant;

	UITableViewCell		*mMapRow;
	MKMapView			*mMapView;

	UITableViewCell		*mRestaurantHeader;
	UIView				*mFooter;
	
	
	UILabel				*mRestaurantName;
	UILabel				*mRestaurantAddress;
	UIButton			*mRestaurantPhone;
	UIImageView			*mRestaurantImage;
	UIView				*mMapOverlay;
	
	UIButton			*mMapButton;
	BOOL				mMapShowing;
	
	UIImageView			*mCameraImage;
	UIImage				*mNewPicture;
	
	SEL					mPostLoginAction;
	
	UIButton			*mFlagView;
	
	UIView				*mMenuSectionHeaderView;
}

@property (nonatomic, retain)			Restaurant		*restaurant;

@property (nonatomic, retain) IBOutlet	UITableViewCell	*restaurantHeader;
@property (nonatomic, retain) IBOutlet	UIView			*footerView;


@property (nonatomic, retain) IBOutlet	UILabel			*restaurantName;
@property (nonatomic, retain) IBOutlet	UILabel			*restaurantAddress;
@property (nonatomic, retain) IBOutlet	UIButton			*restaurantPhone;
@property (nonatomic, retain) IBOutlet	UIImageView		*restaurantImage;

@property (nonatomic, retain) IBOutlet	UITableViewCell	*mapRow;
@property (nonatomic, retain) IBOutlet	MKMapView		*mapView;
@property (nonatomic, retain) IBOutlet	UIView			*mapOverlay;
@property (nonatomic, retain)			UIButton		*mapButton;

@property (nonatomic, retain) IBOutlet	UIImageView		*cameraImage;
@property (nonatomic, retain)			UIImage			*newPicture;

@property (nonatomic, retain) IBOutlet	UIButton		*flagView;
@property (nonatomic, retain) IBOutlet	UIView			*menuSectionHeaderView;

-(IBAction)callRestaurant;
-(IBAction) pushAddDishViewController;
-(IBAction)flagThisRestaurant;

@end
