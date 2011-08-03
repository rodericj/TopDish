//
//  Logger.h
//  TopDish
//
//  Created by roderic campbell on 7/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Logger : NSObject {
    
}
+(void)logEvent:(NSString *)event;
+(void)logEvent:(NSString *)event withDictionary:(NSDictionary *)dict;

@end
