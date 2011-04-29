//
//  AccountView.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "LoginModalView.h"
#import "AppModel.h"
#import "LeaveFeedbackViewController.h"

@interface AccountView : UITableViewController <FBRequestDelegate, 
FBSessionDelegate, LoginModalViewDelegate, AppModelLogoutDelegate,
LeaveFeedbackViewControllerDelegate> {
	UILabel *mUserName;
	UILabel *mUserSince;
	UIView *mTableHeader;
	UIImageView *mUserImage;
	
	FBRequest *mImageRequest;
	
	NSMutableArray *mLifestyleTags;
	
	BOOL mPendingLogin;
	
	FBLoginButton *mFBLoginButton;
}

@property (nonatomic, retain) IBOutlet UILabel *userName;
@property (nonatomic, retain) IBOutlet UILabel *userSince;
@property (nonatomic, retain) IBOutlet UIView *tableHeader;
@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain)  NSMutableArray *lifestyleTags;
@property (nonatomic, retain) FBRequest *imageRequest;
@property (nonatomic, retain) IBOutlet FBLoginButton *fBLoginButton;

- (IBAction)fbButtonClick:(id)sender;

@end
