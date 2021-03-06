//
//  IncomingProcessor.h
//  TopDish
//
//  Created by roderic campbell on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IncomingProcessorDelegate

@optional
-(void)saveError:(NSString *)errorMessage;

@required
-(void)saveDishesComplete:(NSArray *)newRestaurantIds;
-(void)saveRestaurantsComplete;

@end

@interface IncomingProcessor : NSObject {
	NSMutableData *mResponseData;
	
	NSManagedObjectContext *mManagedObjectContext;
	id<IncomingProcessorDelegate> mIncomingProcessorDelegate;
	NSPersistentStoreCoordinator *mPersistentStoreCoordinator;
}

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) id<IncomingProcessorDelegate> incomingProcessorDelegate;

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+(IncomingProcessor *)processorWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator Delegate:(id<IncomingProcessorDelegate>)delegate;

-(void)processIncomingNetworkText:(NSString *)responseText;
- (NSOperation*)taskWithData:(id)data;




@end
