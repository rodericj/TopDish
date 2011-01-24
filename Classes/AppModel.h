//
//  AppModel.h
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppModel : NSObject {
	NSMutableDictionary *mUser;
	NSArray *mMealTypeTags;
	NSArray *mPriceTags;
	int mSelectedPrice;
	int mSelectedMealType;
}

@property (nonatomic, retain) NSMutableDictionary *user;
@property (nonatomic, retain) NSArray *mealTypeTags;
@property (nonatomic, retain) NSArray *priceTags;
@property (nonatomic, assign) int selectedPrice;
@property (nonatomic, assign) int selectedMealType;

+(AppModel *)instance;
@end
