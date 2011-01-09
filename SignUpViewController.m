//
//  SignUpViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController

-(IBAction)submitClicked
{
	NSLog(@"username %@, password %@ %@", 
		  self.userNameTextField.text, 
		  self.passwordTextField.text, 
		  self.confirmPasswordTextField.text);
}

//see parent class for cancel clicked

@end
