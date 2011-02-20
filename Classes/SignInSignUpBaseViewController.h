//
//  SignInSIgnUpBaseViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoggedInLoggedOutGate.h"
#import "FBConnect.h"
#import "FBLoginButton.h"


@interface SignInSignUpBaseViewController : UIViewController <UIAlertViewDelegate,
											FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{
	UITextField *mUserNameTextField;
	UITextField *mPasswordTextField;
	UITextField *mConfirmPasswordTextField;
	
}

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet FBLoginButton *fbLoginButton;

-(IBAction)submitClicked;
-(IBAction)cancelClicked;
-(IBAction)signUpClicked;
-(IBAction)fbButtonClick:(id)sender;

@end
