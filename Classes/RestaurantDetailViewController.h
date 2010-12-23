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
	
	IBOutlet UIView *restaurantHeader;
	IBOutlet UILabel *restaurantName;
	IBOutlet UILabel *restaurantAddress;
	IBOutlet UILabel *restaurantPhone;
	IBOutlet UIImageView *restaurantImage;
	//NSManagedObjectContext *mManagedObjectContext;

}
@property (nonatomic, retain) Restaurant *restaurant;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
