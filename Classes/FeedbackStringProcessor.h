//
//  FeedbackStringProcessor.h
//  TopDish
//
//  Created by roderic campbell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface FeedbackStringProcessor : NSObject {

}

+(NSString *)buildStringFromRequest:(ASIHTTPRequest *)request;
+(BOOL)SendFeedback:(NSString *)feedback delegate:(id)delegate;

@end
