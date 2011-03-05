//
//  SignInViewController.h
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SignInSignUpBaseViewController.h"
#import "ASIFormDataRequest.h"

@interface SignInViewController : SignInSignUpBaseViewController {
	ASIFormDataRequest *mTopDishFBLoginRequest;
	FBLoginButton *mFbLoginButton;
}

@end
