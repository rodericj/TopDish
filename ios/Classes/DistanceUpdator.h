//
//  DistanceUpdator.h
//  TopDish
//
//  Created by roderic campbell on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DistanceUpdatorDelegate
@required
-(void)distancesUpdated;
@end

@interface DistanceUpdator : NSObject {

	NSManagedObjectContext *mManagedObjectContext;
	id<DistanceUpdatorDelegate> mDistanceUpdatorDelegate;
	NSPersistentStoreCoordinator *mPersistentStoreCoordinator;

}

@property (nonatomic, assign) id<DistanceUpdatorDelegate> distanceUpdatorDelegate;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(DistanceUpdator *)updatorWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator Delegate:(id<DistanceUpdatorDelegate>)delegate;
-(void)reprocessAllDistances;
- (NSOperation*)taskWithData:(id)data;

@end
