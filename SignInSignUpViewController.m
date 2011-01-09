//
//  SignInSignUpViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInSignUpViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"

@implementation SignInSignUpViewController
@synthesize signInButton = mSignInButton;
@synthesize signUpButton = mSignUpButton;

-(void)viewDidLoad
{
	[super viewDidLoad];
	//self.navigationController.navigationBar.backItem.hidesBackButton = YES; 
}

-(IBAction)signInClicked
{
	[self.navigationController.navigationBar.backItem setHidesBackButton:YES];

	SignInViewController *signIn = [[SignInViewController alloc] initWithNibName:@"SignIn" bundle:nil];
	[self.navigationController pushViewController:signIn animated:YES];
	[signIn release];	
}

-(IBAction)signUpClicked
{
	SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:@"SignUp" bundle:nil];
	[self.navigationController pushViewController:signUp animated:YES];
	[signUp release];	
}

-(void)dealloc
{	
	[super dealloc];
	self.signInButton = nil;
	self.signUpButton = nil;
}

@end
