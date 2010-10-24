//
//  NearbyMapViewController.m
//
//  Created by Roderic Campbell on 10/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyMapViewController.h"
#import "DishAnnotation.h"
#import "Dish.h"

@implementation NearbyMapViewController
@synthesize mapView;
@synthesize returnButton;
@synthesize nearbyObjects;

- (void)viewDidLoad {
    [super viewDidLoad];
	DishAnnotation *thisAnnotation;
	CLLocationCoordinate2D c;
	float smallestLat=999, smallestLon = 999, largestLat=-999, largestLon=-999;
	for (int i = 0; i < [nearbyObjects count]; i++) {
		Dish *dish = [nearbyObjects objectAtIndex:i];
		float lat = [dish.latitude floatValue];
		float lon = [dish.longitude floatValue];
		
		//Set up the center
		if (lat > largestLat) {
			largestLat = lat;
		}
		if (lon > largestLon) {
			largestLon = lon;
		}
		if (lat < smallestLat){
			smallestLat = lat;
		}
		if (lon < smallestLon){
			smallestLon = lon;
		}
		c.latitude = lat;
		c.longitude = lon;
		thisAnnotation = [[DishAnnotation alloc] initWithCoordinate:c];
		[thisAnnotation setTitle:[dish dish_name]];
		[mapView addAnnotation:thisAnnotation];
		[thisAnnotation release];
	}
	CLLocationCoordinate2D center;
	center.latitude = (smallestLat + largestLat)/2;
	center.longitude = (smallestLon + largestLon)/2;
	MKCoordinateRegion m;
	m.center = center;
	
	MKCoordinateSpan span;
	span.latitudeDelta = largestLat - smallestLat;
	span.longitudeDelta = largestLon - smallestLon;

	//Set up the span
	m.span = span;
	[mapView setRegion:m animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	NSLog(@"view for annotation...perhaps a click");
	
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	if([annotation isKindOfClass:[DishAnnotation class]]){
		static NSString *DishAnnotationIdentifier = @"stringAnnotationIdentifier";
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
			[mapView dequeueReusableAnnotationViewWithIdentifier:DishAnnotationIdentifier];
		
		if(!annotationView){
			NSLog(@"here? now?");

			annotationView = [[[MKPinAnnotationView alloc]
												  initWithAnnotation:annotation  reuseIdentifier:DishAnnotationIdentifier] autorelease];
			annotationView.canShowCallout = YES;
		}
		NSLog(@"about to return the annotation view %d, %@", [annotationView canShowCallout], [annotation title]);
		return annotationView;
	}
	NSLog(@"returned nil? hmmm");
	return nil;
}

-(void) flipMap{
	[self dismissModalViewControllerAnimated:TRUE]; 
}

@end
