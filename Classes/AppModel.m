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
@synthesize mealTypeTags = mMealTypeTags;
@synthesize priceTags = mPriceTags;
@synthesize selectedMealType = mSelectedMealType;
@synthesize selectedPrice = mSelectedPrice;
@synthesize sorter = mSorter;
@synthesize selectedMealTypeObject = mSelectedMealTypeObject;
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
	self.priceTags = [NSArray arrayWithObjects: @"none", @"under $5", @"$5-10", @"$10-$15", @"$15-$25", @"$25+", nil];
	self.mealTypeTags = [NSArray arrayWithObjects:@"all", @"breakfast", @"lunch", @"dinner", @"dessert", @"appetizer", nil];
	return self;
}

-(void) dealloc
{
	[super dealloc];
	self.user = nil;
}
@end
