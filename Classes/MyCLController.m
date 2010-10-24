#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // send loc updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy >= locationManager.desiredAccuracy || newLocation.verticalAccuracy <= locationManager.desiredAccuracy) {
		[self.delegate locationUpdate:newLocation];
		[self.locationManager stopUpdatingLocation];
	}
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	NSLog(@"Got a location error");
	[self.delegate locationError:error];
}

- (void)dealloc {
	[self.locationManager release];
    [super dealloc];
}

@end
