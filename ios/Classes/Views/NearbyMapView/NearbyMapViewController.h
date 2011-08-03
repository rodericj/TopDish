//
//  NearbyMapViewController.h
//
//  Created by Roderic Campbell on 10/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NearbyMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *mMyMapView;
	NSArray *nearbyObjects;
	NSMutableDictionary *mObjectMap;
@private
	
}
@property (nonatomic, retain) IBOutlet MKMapView *myMapView;
@property (nonatomic, retain) NSArray *nearbyObjects;
@property (nonatomic, retain) NSMutableDictionary *objectMap;

@end

