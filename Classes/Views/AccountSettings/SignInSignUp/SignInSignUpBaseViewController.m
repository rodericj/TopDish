    //
//  SignInSIgnUpBaseViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInSignUpBaseViewController.h"


@implementation SignInSignUpBaseViewController



-(IBAction)submitClicked{
	DLog(@"no-op submitClicked");
}


-(IBAction)cancelClicked
{
	
	//[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{		
	[super dealloc];
//	self.passwordTextField = nil;
//	self.confirmPasswordTextField = nil;
//	self.userNameTextField = nil;
	
}


@end
