//
//  BTVenueAnnotation.h
//  Traps
//
//  Created by Roderic Campbell on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DishAnnotation : NSObject <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	//NSString *imageURL;
	//int someint;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
//@property (nonatomic, readonly) NSString *imageURL;
//@property (nonatomic, readwrite) int someint;

@end
