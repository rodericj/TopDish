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
#import "FeedbackStringProcessor.h"

@implementation AppModel

@synthesize user = mUser;
@synthesize selectedMeal = mSelectedMeal;
@synthesize selectedPrice = mSelectedPrice;
@synthesize selectedAllergen = mSelectedAllergen;
@synthesize selectedLifestyle = mSelectedLifestyle;
@synthesize selectedCuisine = mSelectedCuisine;

@synthesize currentLocation = mCurrentLocation;

@synthesize sorter = mSorter;
@synthesize facebook = mFacebook;

@synthesize queue = mQueue;
@synthesize userDelayedLogin = mUserDelayedLogin;

@synthesize imageCache = mImageCache;

AppModel *gAppModelInstance = nil;

+(AppModel *) instance{
	
	if (!gAppModelInstance) {
		gAppModelInstance = [[AppModel alloc] init];
		gAppModelInstance.sorter = 1;
		NSOperationQueue *q = [[NSOperationQueue alloc] init];
		[q setMaxConcurrentOperationCount:1];
		[gAppModelInstance setQueue:q];
		[q release];
	}
	return gAppModelInstance;
}

-(NSArray *) priceTags {
	return mPriceTags;
}
-(void) setPriceTags:(NSArray *)tags {
	mPriceTags = [tags retain];
	[self updateTags:tags];
}

-(void) setMealTypeTags:(NSArray *)tags {
	mMealTypeTags = [tags retain];
	[self updateTags:tags];
}
-(NSArray *) mealTypeTags {
	return mMealTypeTags;
}

-(void) setAllergenTags:(NSArray *)tags {
	mAllergenTags = [tags retain];
	[self updateTags:tags];
}

-(NSArray *) allergenTags {
	return mAllergenTags;
}
-(void) setLifestyleTags:(NSArray *)tags {
	mLifestyleTags = [tags retain];
	[self updateTags:tags];
}

-(NSArray *) lifestyleTags {
	return mLifestyleTags;
}

-(void) setCuisineTypeTags:(NSArray *)tags {
	mCuisineTypeTags = [tags retain];
	[self updateTags:tags];
}

-(NSArray *) cuisineTypeTags {
	return mCuisineTypeTags;
}

-(void) updateTags:(NSArray *)tags {
	if (!mIdToTagLookup) {
		mIdToTagLookup = [[NSMutableDictionary dictionary] retain];
	}
	
	for (NSDictionary *tag in tags) {
		//DLog(@"tag is %@", tag);
		[mIdToTagLookup setObject:tag forKey:[tag objectForKey:@"id"]];
	}
	
}
-(void)createFacebookObject {
	
	self.facebook = [[Facebook alloc] initWithAppId:kFBAppId];	

	if ([[NSUserDefaults standardUserDefaults] objectForKey:TD_FB_ACCESS_TOKEN_KEY]) {
		self.facebook.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:TD_FB_ACCESS_TOKEN_KEY];
		self.facebook.expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:TD_FB_EXPIRATION_DATE_KEY];
		
		//If the facebook session is valid, call fbDidLogin
		if([self.facebook  isSessionValid]) {
			NSLog(@"session is valid");
			[self fbDidLogin];
		}
		//otherwise, attempt to login
		else {
			NSLog(@"session is not valid");
			[self.facebook authorize:kpermission delegate:self];
		}
	}
}

-(id)init
{
	self = [super init];
	self.user = [NSMutableDictionary new];
	[self createFacebookObject];
	return self;
}
-(NSString *)selectedMealName {
	if ([self.selectedMeal intValue] != 0) {
		return [self tagNameForTagId:self.selectedMeal];
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
	if ([self.selectedLifestyle intValue] != 0) {
		return [self tagNameForTagId:self.selectedLifestyle];
	}
	return nil;
}

-(NSString *)selectedCuisineName {
	if ([self.selectedCuisine intValue] != 0) {
		return [self tagNameForTagId:self.selectedCuisine];
	}
	return nil;
}

-(NSString *)selectedAllergenName {
	if ([self.selectedAllergen intValue] != 0) 
		return [self tagNameForTagId:self.selectedAllergen];
	return nil;
}

-(void)setMealTypeByIndex:(int)index {
	NSNumber *selected = [[mMealTypeTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedMeal:selected];
}
-(void)setPriceTypeByIndex:(int)index {
	NSNumber *selected = [[self.priceTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedPrice:selected];
}
-(void)setLifestyleTypeByIndex:(int)index {
	NSNumber *selected = [[mLifestyleTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedLifestyle:selected];
}

-(void)setCuisineTypeByIndex:(int)index {
	NSNumber *selected = [[mCuisineTypeTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedCuisine:selected];
}

-(void)setAllergenTypeByIndex:(int)index {
	NSNumber *selected = [[mAllergenTags objectAtIndex:index] objectForKey:@"id"];
	[self setSelectedAllergen:selected];
}

-(NSString *)tagNameForTagId:(NSNumber *)tagId {
	//we have a lookup for this very common task
	if (!mIdToTagLookup) {
		return nil;
	}
	//NSDictionary *d = [mIdToTagLookup objectForKey:tagId];
	//NSString *a = [d objectForKey:@"name"];
	//TODO figure out why i'm not getting anything here
	//DLog(@"at this point we are getting basically nothing out of the dictionary %@ %@", mIdToTagLookup, a);
	return [[mIdToTagLookup objectForKey:tagId] objectForKey:@"name"];
}
#pragma mark -
#pragma mark login stuff

-(void)logoutWithDelegate:(id<AppModelLogoutDelegate>)logoutDelegate {
	mLogoutDelegate = logoutDelegate;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:TD_FB_ACCESS_TOKEN_KEY];
	[defaults removeObjectForKey:TD_FB_EXPIRATION_DATE_KEY];
	[defaults synchronize];
	
	[self.user removeObjectForKey:keyforauthorizing];
	[self.facebook logout:self];
}

-(BOOL)isLoggedIn {
	return [self.user objectForKey:keyforauthorizing] != nil;
}

#pragma mark -
-(BOOL)isAnyFilterSet {
	return ([self.selectedCuisine intValue] +
	[self.selectedMeal intValue] +
	[self.selectedLifestyle intValue]+
	[self.selectedPrice intValue]+
	[self.selectedAllergen intValue]) > 0;	
}
#pragma mark -
#pragma mark network callback 
- (void)requestFinished:(ASIHTTPRequest *)request
{
	if ([[request.url absoluteString] rangeOfString:@"api/feedback"].location != NSNotFound) {
		NSLog(@"this is a feedback one");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feedback"
														message:request.responseStatusMessage 
													   delegate:nil 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	//Send feedback if broken
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		return;
	}
	// Use when fetching binary data
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSString *responseString = [request responseString];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	[parser release];
	DLog(@"the dictionary should be a %@", responseAsDict);
	
	if (request == mTopDishFBLoginRequest) {
		//responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		DLog(@"handle the facebook authentication stuff %@", responseString);
		if ([[responseAsDict objectForKey:@"rc"] intValue] != 0) {
			//response returned with an error. Lets see what we got
			DLog(@"response from TD Server %@", responseAsDict);
			[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringFailedLogin object:nil];

		}
		else {
			[self.user setObject:[responseAsDict objectForKey:keyforauthorizing] forKey:keyforauthorizing];
			
			//send notification that we have logged in
			[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneLogin object:nil];
		}
		
	}
	else 
		DLog(@"not really sure what we just returned %@", responseAsDict);
}

#pragma mark -
#pragma mark FBcallbacks

-(void)fbDidLogout {
	self.facebook = nil;
	[self createFacebookObject];
	[mLogoutDelegate appModelDidLogout];
}

- (void)fbDidLogin{	
	DLog(@"fb logged in");
	
	//Notify someone
	[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneFacebookLogin object:nil];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/facebookLogin", NETWORKHOST]];
	DLog(@"[[AppModel instance] facebook].accessToken %@\n the url we are hitting is %@", 
		 self.facebook.accessToken, url);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.facebook.accessToken forKey:TD_FB_ACCESS_TOKEN_KEY];
    [defaults setObject:self.facebook.expirationDate forKey:TD_FB_EXPIRATION_DATE_KEY];    
	[defaults synchronize];
	
	//Call the topdish server to log in
	mTopDishFBLoginRequest = [ASIFormDataRequest requestWithURL:url];
	[mTopDishFBLoginRequest setPostValue:self.facebook.accessToken forKey:@"facebookApiKey"];
	[mTopDishFBLoginRequest setAllowCompressedResponse:NO];
	[mTopDishFBLoginRequest setDelegate:self];	
	[mTopDishFBLoginRequest startAsynchronous];
	
}

+(NSNumber *)extractTag:(NSString *)key fromArrayOfTags:(NSArray *)tagsArray {
	for (NSDictionary *tagDict in tagsArray){
		if ([[tagDict objectForKey:@"type"] isEqualToString:key]) {
			return [tagDict objectForKey:@"id"];
		}
	}
	return nil;
}
-(BOOL)doesCacheItemExist:(NSString *)url size:(int)size{
    if (!self.imageCache) {
        self.imageCache = [[ImgCache alloc] init];
    }
    return [self.imageCache doesCacheItemExist:[NSString stringWithFormat:@"%@=s%d-c", url, size]];
}

-(UIImage *)getImage:(NSString *)url size:(int)size{
    if (!self.imageCache) {
        self.imageCache = [[ImgCache alloc] init];
    }
    
    return [self.imageCache getImage:[NSString stringWithFormat:@"%@=s%d-c", url, size]];
}

-(void) dealloc
{
    self.imageCache = nil;
	self.user = nil;
	[mMealTypeTags release];
	[mCuisineTypeTags release];
	[mPriceTags release];
	[mAllergenTags release];
	[mLifestyleTags release];
	self.selectedMeal = nil;
	self.selectedPrice = nil;
	self.selectedAllergen = nil;
	self.selectedLifestyle = nil;
	self.selectedCuisine = nil;
	
	//release the private
	[mIdToTagLookup release];
	
	[super dealloc];
}
@end
