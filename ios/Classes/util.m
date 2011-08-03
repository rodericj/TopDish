//
//  util.m
//  TopDish
//
//  Created by roderic campbell on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "util.h"


@implementation util
+(NSArray *)getArrayOfIdsWithArray:(NSArray *)responseAsArray withKey:(NSString *)key{
	NSEnumerator *enumerator = [responseAsArray objectEnumerator];
	id anObject;
	NSMutableArray *ret = [NSMutableArray array];
	while (anObject = (NSDictionary *)[enumerator nextObject]){
		[ret addObject:[anObject objectForKey:key]];
	}
	//NSLog(@"At the end of all that, the return is %@", ret);
	[ret sortUsingSelector:@selector(compare:)];
	return ret;
}

@end
