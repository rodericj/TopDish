//
//  SignInSignUpViewController.h
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoggedInLoggedOutGate.h"

@interface SignInSignUpViewController : UIViewController {
	UIButton *mSignInButton;
	UIButton *mSignUpButton;
}

@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIButton *signUpButton;

-(IBAction)signInClicked;
-(IBAction)signUpClicked;

@end
