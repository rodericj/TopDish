//
//  NearbyMapViewController.m
//
//  Created by Roderic Campbell on 10/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyMapViewController.h"
#import "RestaurantOrDishAnnotation.h"
#import "Dish.h"
#import "DishDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "constants.h"
#import "Logger.h"

@implementation NearbyMapViewController
@synthesize myMapView = mMyMapView;
@synthesize nearbyObjects;
@synthesize objectMap = mObjectMap;

-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventNMViewDidAppear];
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	RestaurantOrDishAnnotation *thisAnnotation;
	CLLocationCoordinate2D c;
	float smallestLat=999, smallestLon = 999, largestLat=-999, largestLon=-999;
	for (int i = 0; i < [nearbyObjects count]; i++) {
		ObjectWithImage *restOrDishObject = [nearbyObjects objectAtIndex:i];
		
		//Add dish to this MapView's dish Dictionary
		if(self.objectMap == nil){
			self.objectMap = [[NSMutableDictionary alloc] init];
		}
		if ([restOrDishObject respondsToSelector:@selector(dish_id)]) {
			[self.objectMap setObject:restOrDishObject forKey:[(Dish*)restOrDishObject dish_id]];
		}
		else
			[self.objectMap setObject:restOrDishObject forKey:[(Restaurant *)restOrDishObject restaurant_id]];

		
		float lat = [restOrDishObject.latitude floatValue];
		float lon = [restOrDishObject.longitude floatValue];
		
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
		
		thisAnnotation = [[RestaurantOrDishAnnotation alloc] initWithCoordinate:c];
		[thisAnnotation setTitle:[restOrDishObject objName]];
		[thisAnnotation setThisObjectWithImage:restOrDishObject];
		
		[self.myMapView addAnnotation:thisAnnotation];
		[thisAnnotation release];
	}
	CLLocationCoordinate2D center;
	center.latitude = (smallestLat + largestLat)/2;
	center.longitude = (smallestLon + largestLon)/2;
	MKCoordinateRegion m;
	m.center = center;
	
	MKCoordinateSpan span;
	span.latitudeDelta = (largestLat - smallestLat) * 1.5;
	span.longitudeDelta = (largestLon - smallestLon ) * 1.5; 

	//Set up the span
	m.span = span;
	[self.myMapView setRegion:m animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	if([annotation isKindOfClass:[RestaurantOrDishAnnotation class]]){
		static NSString *DishAnnotationIdentifier = @"stringAnnotationIdentifier";

		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
			[self.myMapView dequeueReusableAnnotationViewWithIdentifier:DishAnnotationIdentifier];
		
		if(!annotationView){
			annotationView = [[[MKPinAnnotationView alloc]
												  initWithAnnotation:annotation  
							   reuseIdentifier:DishAnnotationIdentifier] autorelease];
			annotationView.canShowCallout = YES;
		}
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		//annotation = (DishAnnotation *)annotation;
		ObjectWithImage *obj = [annotation thisObjectWithImage];
		if ([obj respondsToSelector:@selector(dish_id)]) {
			rightButton.tag = [[(Dish *)obj dish_id] intValue];
		}
		else {
			rightButton.tag = [[(Restaurant *)obj restaurant_id] intValue];

		}

		annotationView.rightCalloutAccessoryView = rightButton;		
		return annotationView;
	}
	return nil;
}

- (void)showDetails:(id)sender
{
    [Logger logEvent:kEventNMShowDetails];
	NSNumber *clickedObjectId = [NSNumber numberWithInt:[sender tag]];
	ObjectWithImage *selectedObject = [self.objectMap objectForKey:clickedObjectId];
	
	if ([selectedObject respondsToSelector:@selector(dish_id)]) {
		DishDetailViewController *dishDetailViewController = [[DishDetailViewController alloc] 
															 initWithNibName:@"DishDetailViewController" 
															 bundle:nil];
		dishDetailViewController.thisDish = (Dish *)selectedObject;
		[self.navigationController pushViewController:dishDetailViewController animated:YES];
		[dishDetailViewController release];
	}
	else {
        
        RestaurantDetailViewController *restaurantController = [RestaurantDetailViewController restaurantDetailViewWithRestaurant:(Restaurant *)selectedObject];
        [self.navigationController pushViewController:restaurantController animated:YES];
        
    }
}

#pragma mark - Map Movement
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[Logger logEvent:kEventNMMoveMap];
	CLLocation *rightSide = [[CLLocation alloc] initWithLatitude: mapView.centerCoordinate.latitude + (mapView.region.span.latitudeDelta)
													   longitude:mapView.centerCoordinate.longitude];
	CLLocation *center = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude
													longitude:mapView.centerCoordinate.longitude];
	//float dist = [rightSide distanceFromLocation:center]/kOneMileInMeters;
	
	
	[rightSide release];
	[center release];
}

-(void)dealloc {
	self.myMapView.delegate = nil;
	self.myMapView = nil;
	self.nearbyObjects = nil;
	self.objectMap = nil;
	[super dealloc];
}

@end
