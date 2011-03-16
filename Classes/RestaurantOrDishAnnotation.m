//
//  RestaurantOrDishAnnotation.m
//  Traps
//
//  Created by Roderic Campbell on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RestaurantOrDishAnnotation.h"


@implementation RestaurantOrDishAnnotation
@synthesize thisObjectWithImage = mThisObjectWithImage;
@synthesize coordinate;
@synthesize title;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
