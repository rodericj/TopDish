//
//  AppModel.m
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppModel.h"
#import "constants.h"
#import "JSON.h"

@implementation AppModel

@synthesize user = mUser;
@synthesize mealTypeTags = mMealTypeTags;
@synthesize cuisineTypeTags = mCuisineTypeTags;
@synthesize priceTags = mPriceTags;
@synthesize allergenTags = mAllergenTags;
@synthesize lifestyleTags = mLifestyleTags;
@synthesize selectedMealType = mSelectedMealType;
@synthesize selectedPrice = mSelectedPrice;
@synthesize selectedAllergen = mSelectedAllergen;
@synthesize selectedLifestyle = mSelectedLifestyle;
@synthesize sorter = mSorter;
@synthesize selectedMealTypeObject = mSelectedMealTypeObject;
@synthesize facebook = mFacebook;
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
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	NSLog(@"mobileInitResponseText %@", mobileInitResponseText);
	NSArray *responseAsArray = [parser objectWithString:mobileInitResponseText error:&error];	
	NSLog(@"response Array is %@", responseAsArray);
	if (error)
		NSLog(@"there was an error when jsoning in AppModel Init %@", error);
	NSArray *objectArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
							@"No Filter", [NSNumber numberWithInt:0],
							@"No Filter", nil];
	NSArray *keyArray = [NSArray arrayWithObjects:@"id", 
						 @"name", @"order", @"type", nil];
	NSDictionary *d = [NSDictionary dictionaryWithObjects:objectArray 
												  forKeys:keyArray];
	NSMutableArray *priceTypeTags = [NSMutableArray arrayWithObject:d];
	NSMutableArray *mealTypeTags = [NSMutableArray arrayWithObject:d];
	for (d in responseAsArray)
	{
		NSLog(@"this dictionary %@", d);
		if ([[d objectForKey:@"type"] isEqualToString:kMealTypeString])
			[mealTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kPriceTypeString])
			[priceTypeTags addObject:d];
		
	}
	[parser release];
	self.priceTags = priceTypeTags;
	self.mealTypeTags = mealTypeTags;
	self.facebook = [[Facebook alloc] initWithAppId:kFBAppId];
	return self;
}

-(void) dealloc
{
	[super dealloc];
	self.user = nil;
}
@end
