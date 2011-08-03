//
//  FeedbackStringProcessor.m
//  TopDish
//
//  Created by roderic campbell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedbackStringProcessor.h"
#import "constants.h"
#import "ASIFormDataRequest.h"
#import "AppModel.h"

@implementation FeedbackStringProcessor

+(NSString *)buildStringFromRequest:(ASIHTTPRequest *)request {
	return [NSString stringWithFormat:@"\ncode: %d\nMessage: %@\nURL: %@\n %@\n\n%@", request.responseStatusCode,
			request.responseStatusMessage, request.url, [NSThread callStackSymbols], [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease]];
}

+(BOOL)SendFeedback:(NSString *)feedback delegate:(id)delegate {
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/sendUserFeedback"]];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	NSString *feedbackString = [NSString stringWithFormat:@"%@ \nAuthKey:%@", 
								feedback, 
								[[[AppModel instance] user] objectForKey:keyforauthorizing]];
	
	[request setPostValue:feedbackString 
				   forKey:@"feedback"];	
	
	[request setPostValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
				   forKey:@"platform"];	
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing]
				   forKey:@"apiKey"];	
	[request setDelegate:delegate];
	[request startAsynchronous];
	
	return TRUE;
	
}

@end
