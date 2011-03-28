#import "MyCLController.h"
#import "constants.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	DLog(@"got a new location");
	if (newLocation.horizontalAccuracy >= locationManager.desiredAccuracy || newLocation.verticalAccuracy <= locationManager.desiredAccuracy) {
		DLog(@"good enough location");
		[self.delegate locationUpdate:newLocation];
		[self.locationManager stopUpdatingLocation];
	}
	else {
		DLog(@"it wasn't good enough");
	}

}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	DLog(@"Got a location error");
	[self.delegate locationError:error];
}

- (void)dealloc {
	self.locationManager = nil;
    [super dealloc];
}

@end
