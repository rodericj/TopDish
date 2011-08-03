//
//  CustomNSURLConnection.m
//  TopDish
//
//  Created by roderic campbell on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomNSURLConnection.h"


@implementation NSURLConnection (hasCopyWithZone)

- (id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

@end
