//
//  IncomingProcessor.h
//  TopDish
//
//  Created by roderic campbell on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IncomingProcessorDelegate
-(void)saveComplete;
@end

@interface IncomingProcessor : NSObject {
	NSMutableData *mResponseData;
	
	NSManagedObjectContext *mManagedObjectContext;
	id<IncomingProcessorDelegate> mIncomingProcessorDelegate;
}

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) id<IncomingProcessorDelegate> incomingProcessorDelegate;

+(IncomingProcessor *)processorWithDelegate:(id<IncomingProcessorDelegate>)delegate;

-(void)processIncomingNetworkText:(NSString *)responseText;
- (NSOperation*)taskWithData:(id)data;




@end
