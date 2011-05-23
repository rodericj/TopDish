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

@protocol LoginModalViewDelegate

@required
-(void)noLoginNow;
-(void)loginComplete;
-(void)loginStarted;

-(void)facebookLoginComplete;
-(void)loginFailed;
@end

@interface LoginModalView : UIViewController <MBProgressHUDDelegate, 
UIGestureRecognizerDelegate, 
UIWebViewDelegate>{
	FBLoginButton				*mFbLoginButton;
	id<LoginModalViewDelegate>	mDelegate;
	MBProgressHUD				*mHud;
	UILabel						*mNotNowLabel;
	UIWebView					*mGoogleLoginView;
}

@property (nonatomic, retain) IBOutlet	FBLoginButton				*fbLoginButton;
@property (nonatomic, assign)			id<LoginModalViewDelegate>	delegate;
@property (nonatomic, assign)			MBProgressHUD				*hud;
@property (nonatomic, assign) IBOutlet	UILabel						*notNowLabel;
@property (nonatomic, retain) IBOutlet	UIWebView					*googleLoginView;

+(LoginModalView *)viewControllerWithDelegate:(id<LoginModalViewDelegate>)delegate;

//-(void)handleNotNowGesture:(UIGestureRecognizer *)recognizer;
-(IBAction)fbButtonClick:(id)sender;
-(IBAction)googleButtonClick:(id)sender;
@end