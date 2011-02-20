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
@synthesize selectedMeal = mSelectedMeal;
@synthesize selectedPrice = mSelectedPrice;
@synthesize selectedAllergen = mSelectedAllergen;
@synthesize selectedLifestyle = mSelectedLifestyle;
@synthesize selectedCuisine = mSelectedCuisine;

@synthesize currentLocation = mCurrentLocation;

@synthesize sorter = mSorter;
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
	NSMutableArray *allergenTags = [NSMutableArray arrayWithObject:d];
	NSMutableArray *lifestyleTags = [NSMutableArray arrayWithObject:d];
	for (d in responseAsArray)
	{
		NSLog(@"this dictionary %@", d);
		if ([[d objectForKey:@"type"] isEqualToString:kMealTypeString])
			[mealTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kPriceTypeString])
			[priceTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kAllergenTypeString])
			[allergenTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kLifestyleTypeString])
			[lifestyleTags addObject:d];
		
	}
	[parser release];
	self.priceTags = priceTypeTags;
	self.mealTypeTags = mealTypeTags;
	self.facebook = [[Facebook alloc] initWithAppId:kFBAppId];
	return self;
}
-(NSString *)selectedMealName {
	if ([self.selectedMeal intValue] != 0) 

	for (NSDictionary *meal in self.mealTypeTags) {
		if ([meal objectForKey:@"id"] == self.selectedMeal) {
			return [meal objectForKey:@"name"];
		}
	}
	return nil;
}

-(NSString *)selectedPriceName {
	if ([self.selectedPrice intValue] != 0) 

	for (NSDictionary *price in self.priceTags) {
		if ([price objectForKey:@"id"] == self.selectedPrice) {
			return [price objectForKey:@"name"];
		}
	}
	return nil;
}

-(NSString *)selectedLifestyleName {
	if ([self.selectedLifestyle intValue] != 0) 

	for (NSDictionary *lifestyle in self.lifestyleTags) {
		if ([lifestyle objectForKey:@"id"] == self.selectedLifestyle) {
			return [lifestyle objectForKey:@"name"];
		}
	}
	return nil;
}

-(NSString *)selectedCuisineName {
	if ([self.selectedCuisine intValue] != 0) 

	for (NSDictionary *cuisine in self.cuisineTypeTags) {
		if ([cuisine objectForKey:@"id"] == self.selectedCuisine) {
			return [cuisine objectForKey:@"name"];
		}
	}
	return nil;
}

-(NSString *)selectedAllergenName {
	if ([self.selectedAllergen intValue] != 0) 

	for (NSDictionary *allergen in self.allergenTags) {
		if ([allergen objectForKey:@"id"] == self.selectedAllergen) {
			return [allergen objectForKey:@"name"];
		}
	}
	return nil;
}

-(NSNumber *)selectedPriceId {
	for (NSDictionary *price in self.priceTags) {
		if ([price objectForKey:@"id"] == self.selectedPrice) {
			return [price objectForKey:@"id"];
		}
	}
	return nil;
}

-(NSNumber *)selectedMealId {
	for (NSDictionary *meal in self.mealTypeTags) {
		if ([meal objectForKey:@"id"] == self.selectedMeal) {
			return [meal objectForKey:@"id"];
		}
	}
	return 0;
}

-(NSNumber *)selectedLifestyleId {
	for (NSDictionary *lifestyle in self.lifestyleTags) {
		if ([lifestyle objectForKey:@"id"] == self.selectedLifestyle) {
			return [lifestyle objectForKey:@"id"];
		}
	}
	return 0;
}

-(NSNumber *)selectedCuisineId {
		
	for (NSDictionary *cuisine in self.cuisineTypeTags) {
		if ([cuisine objectForKey:@"id"] == self.selectedCuisine) {
			return [cuisine objectForKey:@"id"];
		}
	}
	return 0;
}

-(NSNumber *)selectedAllergenId {
		
	for (NSDictionary *allergen in self.allergenTags) {
		if ([allergen objectForKey:@"id"] == self.selectedAllergen) {
			return [allergen objectForKey:@"id"];
		}
	}
	return 0;
}


-(void)setMealTypeByIndex:(int)index {
	NSNumber *selected = [[self.mealTypeTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedMeal:selected];
}
-(void)setPriceTypeByIndex:(int)index {
	NSNumber *selected = [[self.priceTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedPrice:selected];
}
-(void)setLifestyleTypeByIndex:(int)index {
	NSNumber *selected = [[self.lifestyleTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedLifestyle:selected];
}

-(void)setCuisineTypeByIndex:(int)index {
	NSNumber *selected = [[self.cuisineTypeTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedCuisine:selected];
}

-(void)setAllergenTypeByIndex:(int)index {
	NSNumber *selected = [[self.allergenTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedAllergen:selected];
}

-(void) dealloc
{
	[super dealloc];
	self.user = nil;
}
@end
