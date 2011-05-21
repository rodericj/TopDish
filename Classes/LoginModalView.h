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
-(void)notNowButtonPressed;
-(void)loginComplete;
-(void)loginStarted;

-(void)facebookLoginComplete;
-(void)loginFailed;
@end

@interface LoginModalView : UIViewController <MBProgressHUDDelegate>{
	FBLoginButton				*mFbLoginButton;
	id<LoginModalViewDelegate>	mDelegate;
	MBProgressHUD				*mHud;
}

@property (nonatomic, retain) IBOutlet	FBLoginButton				*fbLoginButton;
@property (nonatomic, assign)			id<LoginModalViewDelegate>	delegate;
@property (nonatomic, assign)			MBProgressHUD				*hud;

+(LoginModalView *)viewControllerWithDelegate:(id<LoginModalViewDelegate>)delegate;

-(IBAction)notNowButtonPressed;
-(IBAction)fbButtonClick:(id)sender;
@end