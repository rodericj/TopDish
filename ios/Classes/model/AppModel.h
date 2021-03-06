//
//  AppModel.h
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "ASIFormDataRequest.h"
#import "ImgCache.h"

@protocol AppModelLogoutDelegate

-(void)appModelDidLogout;

@end


@interface AppModel : NSObject <FBSessionDelegate>{
	NSMutableDictionary *mUser;
	NSArray *mMealTypeTags;
	NSArray *mCuisineTypeTags;
	NSArray *mPriceTags;
	NSArray *mAllergenTags;
	NSArray *mLifestyleTags;
	NSNumber *mSelectedPrice;
	NSNumber *mSelectedMeal;
	NSNumber *mSelectedAllergen;
	NSNumber *mSelectedLifestyle;
	NSNumber *mSelectedCuisine;
	int mSorter;
	NSNumber *mSelectedMealTypeObject;
	Facebook *mFacebook;
	
	CLLocation *mCurrentLocation;
	
	//private
	NSMutableDictionary *mIdToTagLookup;
	
	NSOperationQueue *mQueue;
	
	ASIFormDataRequest *mTopDishFBLoginRequest;
	BOOL	mUserDelayedLogin;
	
	id<AppModelLogoutDelegate> mLogoutDelegate;
    
    ImgCache *mImageCache;
}

@property (nonatomic, retain) NSMutableDictionary *user;

@property (nonatomic, retain) NSNumber *selectedMeal;
@property (nonatomic, retain) NSNumber *selectedPrice;
@property (nonatomic, retain) NSNumber *selectedAllergen;
@property (nonatomic, retain) NSNumber *selectedLifestyle;
@property (nonatomic, retain) NSNumber *selectedCuisine;
@property (nonatomic, assign) int sorter;
@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) NSOperationQueue *queue;

@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, assign) BOOL userDelayedLogin;
@property (nonatomic, retain) ImgCache *imageCache;

+(AppModel *)instance;

-(NSString *)selectedMealName;
-(NSString *)selectedLifestyleName;
-(NSString *)selectedPriceName;
-(NSString *)selectedCuisineName;
-(NSString *)selectedAllergenName;

-(void)setMealTypeByIndex:(int)index;
-(void)setPriceTypeByIndex:(int)index;
-(void)setLifestyleTypeByIndex:(int)index;
-(void)setCuisineTypeByIndex:(int)index;
-(void)setAllergenTypeByIndex:(int)index;

-(NSString *)tagNameForTagId:(NSNumber *)tagId;
-(void) updateTags:(NSArray *)tags;

-(void) setPriceTags:(NSArray *)priceTags;
-(NSArray *) priceTags;

-(void) setAllergenTags:(NSArray *)tags;
-(NSArray *) allergenTags;

-(void) setMealTypeTags:(NSArray *)tags;
-(NSArray *) mealTypeTags;

-(void) setLifestyleTags:(NSArray *)tags;
-(NSArray *) lifestyleTags;

-(void) setCuisineTypeTags:(NSArray *)tags;
-(NSArray *) cuisineTypeTags;

+(NSNumber *)extractTag:(NSString *)key fromArrayOfTags:(NSArray *)tagsArray;

-(BOOL)isAnyFilterSet;
-(BOOL)isLoggedIn;
-(void)logoutWithDelegate:(id<AppModelLogoutDelegate>)logoutDelegate;

//cache
-(UIImage *)getImage:(NSString *)url size:(int)size;
-(BOOL)doesCacheItemExist:(NSString *)url size:(int)size;

@end
