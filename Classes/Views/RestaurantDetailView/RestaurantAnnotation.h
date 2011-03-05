//
//  RestaurantAnnotation.h
//  TopDish
//
//  Created by roderic campbell on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Restaurant.h"

@interface RestaurantAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	Restaurant *mThisRestaurant;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) Restaurant *thisRestaurant;
@property (nonatomic, readonly) NSString *title;

@end
