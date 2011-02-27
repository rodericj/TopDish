//
//  RestaurantAnnotation.m
//  TopDish
//
//  Created by roderic campbell on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestaurantAnnotation.h"


@implementation RestaurantAnnotation
@synthesize coordinate;
@synthesize thisRestaurant = mThisRestaurant;
@synthesize title = mTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
