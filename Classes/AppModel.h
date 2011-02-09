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
	NSArray *mPriceTags;
	NSArray *mAllergenTags;
	NSArray *mLifestyleTags;
	int mSelectedPrice;
	int mSelectedMealType;
	int mSelectedAllergen;
	int mSelectedLifestyle;
	int mSorter;
	NSNumber *mSelectedMealTypeObject;
	Facebook *mFacebook;
}

@property (nonatomic, retain) NSMutableDictionary *user;
@property (nonatomic, retain) NSArray *mealTypeTags;
@property (nonatomic, retain) NSArray *priceTags;
@property (nonatomic, retain) NSArray *allergenTags;
@property (nonatomic, retain) NSArray *lifestyleTags;
@property (nonatomic, assign) int selectedPrice;
@property (nonatomic, assign) int selectedMealType;
@property (nonatomic, assign) int selectedAllergen;
@property (nonatomic, assign) int selectedLifestyle;
@property (nonatomic, assign) int sorter;
@property (nonatomic, assign) NSNumber *selectedMealTypeObject;
@property (nonatomic, assign) Facebook *facebook;


+(AppModel *)instance;
@end
