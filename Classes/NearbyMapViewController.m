//
//  NearbyMapViewController.m
//
//  Created by Roderic Campbell on 10/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyMapViewController.h"
#import "DishAnnotation.h"
#import "Dish.h"
#import "ScrollingDishDetailViewController.h"
#import "Dish.h"

@implementation NearbyMapViewController
@synthesize mapView;
@synthesize nearbyObjects;
@synthesize dishMap;
@synthesize managedObjectContext=managedObjectContext_;

- (void)viewDidLoad {
    [super viewDidLoad];
	DishAnnotation *thisAnnotation;
	CLLocationCoordinate2D c;
	float smallestLat=999, smallestLon = 999, largestLat=-999, largestLon=-999;
	NSMutableDictionary *markerCount = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < [nearbyObjects count]; i++) {
		Dish *dish = [nearbyObjects objectAtIndex:i];
		
		//Add dish to this MapView's dish Dictionary
		if(dishMap == nil){
			dishMap = [[NSMutableDictionary alloc] init];
		}
		[dishMap setObject:dish forKey:[dish dish_id]];
		
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
		NSString *hash = [[NSString alloc] initWithFormat:@"%d %d", lat, lon];
		int count = [[markerCount valueForKey:hash] intValue];
		if(count){
		    [markerCount setValue:[NSNumber numberWithInt:count+1] forKey:hash];
			c.longitude = lon +.0001*count;
		}
		else{
			[markerCount setValue:[NSNumber numberWithInt:1] forKey:hash];
			//c.longitude = lon +.0001;
		}
		[hash release];
		thisAnnotation = [[DishAnnotation alloc] initWithCoordinate:c];
		[thisAnnotation setTitle:[dish dish_name]];
		[thisAnnotation setThisDish:dish];
		
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
	
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	if([annotation isKindOfClass:[DishAnnotation class]]){
		static NSString *DishAnnotationIdentifier = @"stringAnnotationIdentifier";

		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
			[mapView dequeueReusableAnnotationViewWithIdentifier:DishAnnotationIdentifier];
		
		if(!annotationView){
			annotationView = [[[MKPinAnnotationView alloc]
												  initWithAnnotation:annotation  reuseIdentifier:DishAnnotationIdentifier] autorelease];
			annotationView.canShowCallout = YES;
		}
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		//annotation = (DishAnnotation *)annotation;
		rightButton.tag = [[[annotation thisDish] dish_id] intValue];
		annotationView.rightCalloutAccessoryView = rightButton;
		
		NSLog(@"about to return the annotation view %d, %@", [annotationView canShowCallout], [annotation title]);
		return annotationView;
	}
	NSLog(@"returned nil? hmmm");
	return nil;
}

- (void)showDetails:(id)sender
{
	NSNumber *clickedDishId = [[NSNumber alloc] initWithInt:[sender tag]];
	Dish *selectedObject = [dishMap objectForKey:clickedDishId];
	ScrollingDishDetailViewController *detailViewController = [[ScrollingDishDetailViewController alloc] initWithNibName:@"ScrollingDishDetailView" bundle:nil];
	[detailViewController setDish:selectedObject];
	[detailViewController setManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

@end
