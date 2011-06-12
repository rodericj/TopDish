//
//  RestaurantTableViewCell.h
//  TopDish
//
//  Created by roderic campbell on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantTableViewCell : UITableViewCell {
	UILabel			*mRestaurantName;
	UILabel			*mAddress;
	UIImageView		*mRestaurantImageView;
	UILabel			*mPhoneNumber;
	UILabel			*mDistance;
}

@property (nonatomic, retain) IBOutlet UILabel		*restaurantName;
@property (nonatomic, retain) IBOutlet UILabel		*address;
@property (nonatomic, retain) IBOutlet UIImageView	*restaurantImageView;
@property (nonatomic, retain) IBOutlet UILabel		*phoneNumber;
@property (nonatomic, retain) IBOutlet UILabel		*distance;
@end
