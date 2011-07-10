//
//  Logger.m
//  TopDish
//
//  Created by roderic campbell on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Logger.h"
#import "MixpanelAPI.h"

@implementation Logger

+(void)logEvent:(NSString *)event  {
    [[MixpanelAPI sharedAPI] track:event];
}

+(void)logEvent:(NSString *)event withDictionary:(NSDictionary *)dict {
    [[MixpanelAPI sharedAPI] track:event properties:dict];
}
@end
