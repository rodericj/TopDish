//
//  SignInSignUpViewController.h
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoggedInLoggedOutGate.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
@interface SignInSignUpViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
	UIButton *mSignInButton;
	UIButton *mSignUpButton;
	FBLoginButton *mFbLoginButton;
}

@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet FBLoginButton *fbLoginButton;

-(IBAction)signInClicked;
-(IBAction)signUpClicked;
-(IBAction)fbButtonClick:(id)sender;

@end
