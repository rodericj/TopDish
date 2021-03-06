//
//  LoginModalView.h
//  TopDish
//
//  Created by roderic campbell on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginButton.h"
#import "MBProgressHUD.h"
#import "AppModel.h"

@protocol LoginModalViewDelegate

@required
-(void)noLoginNow;
-(void)loginComplete;
-(void)loginStarted;

-(void)facebookLoginComplete;
-(void)loginFailed;
@end

@interface LoginModalView : UIViewController <MBProgressHUDDelegate, 
UIWebViewDelegate, AppModelLogoutDelegate>{
	FBLoginButton				*mFbLoginButton;
	id<LoginModalViewDelegate>	mDelegate;
	MBProgressHUD				*mHud;
	UIWebView					*mGoogleLoginView;
    
    UITextView                  *mWelcomeTextView;
}

@property (nonatomic, retain) IBOutlet	FBLoginButton				*fbLoginButton;
@property (nonatomic, assign)			id<LoginModalViewDelegate>	delegate;
@property (nonatomic, assign)			MBProgressHUD				*hud;
@property (nonatomic, retain) IBOutlet	UIWebView					*googleLoginView;
@property (nonatomic, retain) IBOutlet	UITextView					*welcomeTextView;

+(LoginModalView *)viewControllerWithDelegate:(id<LoginModalViewDelegate>)delegate;

//-(void)handleNotNowGesture:(UIGestureRecognizer *)recognizer;
-(IBAction)fbButtonClick:(id)sender;
-(IBAction)notNowButtonClick:(id)sender;
-(IBAction)googleButtonClick:(id)sender;
-(IBAction)termsAndConditionsButtonClicked:(id)sender;
@end