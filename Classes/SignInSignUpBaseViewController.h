//
//  SignInSIgnUpBaseViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignInSignUpBaseViewController : UIViewController {
	UITextField *mUserNameTextField;
	UITextField *mPasswordTextField;
	UITextField *mConfirmPasswordTextField;
}

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordTextField;

-(IBAction)submitClicked;
-(IBAction)cancelClicked;

@end
