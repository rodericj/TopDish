//
//  DistanceUpdator.m
//  TopDish
//
//  Created by roderic campbell on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DistanceUpdator.h"
#import "constants.h"
#import "Dish.h"
#import "AppModel.h"

@implementation DistanceUpdator

@synthesize distanceUpdatorDelegate = mDistanceUpdatorDelegate;
@synthesize persistentStoreCoordinator = mPersistentStoreCoordinator;

- (NSOperation*)taskWithData:(id)data {
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
																		 selector:@selector(reprocessAllDistances) object:data] autorelease];
	return theOp;
}

+(DistanceUpdator *)updatorWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator Delegate:(id<DistanceUpdatorDelegate>)delegate {


	DistanceUpdator *updator = [[DistanceUpdator alloc] init];
	updator.distanceUpdatorDelegate = delegate;
	updator.persistentStoreCoordinator = coordinator;
	return [updator autorelease];	
}
-(void)reprocessAllDistances {
	DLog(@"This happens in the background");
	//perform fetch
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish" 
											  inManagedObjectContext:kManagedObjectContext];
    fetchRequest.entity = entity;
    
	//Sort Descriptors
	NSSortDescriptor *sortDescriptor = 
	[[NSSortDescriptor alloc] initWithKey:@"objName" 
								ascending:TRUE];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:kManagedObjectContext 
										  sectionNameKeyPath:nil cacheName:nil];
	
	//for each item, change the distance
	if (![aFetchedResultsController performFetch:nil]) {
        DLog(@"Unresolved error");
        abort();
    }
	NSArray *results = [aFetchedResultsController fetchedObjects];
	
	[fetchRequest release];
	[sortDescriptor release];
	[aFetchedResultsController release];
	
	for (Dish *dish in results ){
		CLLocation *l = [[CLLocation alloc] initWithLatitude:[[dish latitude] floatValue] longitude:[[dish longitude] floatValue]];
		CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
		[l release];
		float distanceInMiles = dist/kOneMileInMeters; 
		
		[dish setDistance:[NSNumber numberWithFloat:distanceInMiles]];
	}
	
	if ([results count]) {
		[self.distanceUpdatorDelegate distancesUpdated];
	}
}

@end
