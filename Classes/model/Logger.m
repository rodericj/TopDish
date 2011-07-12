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
    [self logEvent:event withDictionary:[NSMutableDictionary dictionaryWithCapacity:1]];
}

+(void)logEvent:(NSString *)event withDictionary:(NSMutableDictionary *)dict {
   NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    [dict setObject:version forKey:@"clientVersion"];
    [[MixpanelAPI sharedAPI] track:event properties:dict];
}
@end
