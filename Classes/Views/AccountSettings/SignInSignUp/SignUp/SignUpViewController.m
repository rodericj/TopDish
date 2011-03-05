//
//  SignUpViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"
#import "constants.h"

@implementation SignUpViewController

-(void) viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
}

-(IBAction)submitClicked
{
	DLog(@"username %@, password %@ %@", 
		  self.userNameTextField.text, 
		  self.passwordTextField.text, 
		  self.confirmPasswordTextField.text);
}

//see parent class for cancel clicked

@end
