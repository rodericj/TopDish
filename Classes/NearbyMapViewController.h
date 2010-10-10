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
	MKMapView *mapView;
	UIBarButtonItem *returnButton;
	NSArray *nearbyObjects;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSArray *nearbyObjects;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *returnButton;
-(IBAction) flipMap;

@end

