//
//  SignInSignUpViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInSignUpViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "AppModel.h"
#import "constants.h"
#import "AccountView.h"

@implementation SignInSignUpViewController
@synthesize signInButton = mSignInButton;
@synthesize signUpButton = mSignUpButton;

-(void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
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

-(void)viewDidAppear:(BOOL)animated
{		
	[super viewDidAppear:animated];
	NSLog(@"the view will appear. If we have the key, go to the account page");
	AppModel *a = [AppModel instance];
	NSLog(@"the api key is %@", [a.user objectForKey:keyforauthorizing]);
	if ([[AppModel instance].user objectForKey:keyforauthorizing] != nil) {
		AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
		[accountView release];
	}
}
-(void)dealloc
{	
	[super dealloc];
//	self.signInButton = nil;
//	self.signUpButton = nil;
}

@end
