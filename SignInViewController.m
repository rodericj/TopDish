//
//  SignInViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"

@implementation SignInViewController

-(IBAction)submitClicked
{
	NSLog(@"username %@, password %@", 
		  self.userNameTextField.text, 
		  self.passwordTextField.text);
}

//see parent class for cancel clicked

@end
