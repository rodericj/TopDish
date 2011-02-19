//
//  AppModel.h
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface AppModel : NSObject {
	NSMutableDictionary *mUser;
	NSArray *mMealTypeTags;
	NSArray *mCuisineTypeTags;
	NSArray *mPriceTags;
	NSArray *mAllergenTags;
	NSArray *mLifestyleTags;
	int mSelectedPrice;
	NSNumber *mSelectedMeal;
	NSNumber *mSelectedAllergen;
	NSNumber *mSelectedLifestyle;
	NSNumber *mSelectedCuisine;
	int mSorter;
	NSNumber *mSelectedMealTypeObject;
	Facebook *mFacebook;
}

@property (nonatomic, retain) NSMutableDictionary *user;
@property (nonatomic, retain) NSArray *mealTypeTags;
@property (nonatomic, retain) NSArray *cuisineTypeTags;
@property (nonatomic, retain) NSArray *priceTags;
@property (nonatomic, retain) NSArray *allergenTags;
@property (nonatomic, retain) NSArray *lifestyleTags;
@property (nonatomic, assign) int selectedPrice;
@property (nonatomic, retain) NSNumber *selectedMeal;
@property (nonatomic, retain) NSNumber *selectedAllergen;
@property (nonatomic, retain) NSNumber *selectedLifestyle;
@property (nonatomic, retain) NSNumber *selectedCuisine;
@property (nonatomic, assign) int sorter;
@property (nonatomic, assign) Facebook *facebook;


+(AppModel *)instance;

-(NSString *)selectedMealName;
-(NSString *)selectedLifestyleName;
-(NSString *)selectedCuisineName;
-(NSString *)selectedAllergenName;
-(NSNumber *)selectedMealId;
-(NSNumber *)selectedLifestyleId;
-(NSNumber *)selectedCuisineId;
-(NSNumber *)selectedAllergenId;
-(void)setMealTypeByIndex:(int)index;
-(void)setLifestyleTypeByIndex:(int)index;
-(void)setCuisineTypeByIndex:(int)index;
-(void)setAllergenTypeByIndex:(int)index;
@end
