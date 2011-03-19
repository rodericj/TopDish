//
//  IncomingProcessor.h
//  TopDish
//
//  Created by roderic campbell on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IncomingProcessor : NSObject {
	NSMutableData *mResponseData;

}

@property (nonatomic, retain) NSMutableData *responseData;

-(void)processIncomingNetworkText:(NSString *)responseText;
- (NSOperation*)taskWithData:(id)data;


@end
