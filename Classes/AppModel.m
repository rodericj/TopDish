//
//  AppModel.m
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppModel.h"


@implementation AppModel

@synthesize user = mUser;
AppModel *gAppModelInstance = nil;

+(AppModel *) instance{
	
	if (!gAppModelInstance) {
		gAppModelInstance = [[AppModel alloc] init];
	}
	return gAppModelInstance;
}

-(id)init
{
	self = [super init];
	self.user = [NSMutableDictionary new];
	return self;
}

-(void) dealloc
{
	[super dealloc];
	self.user = nil;
}
@end
