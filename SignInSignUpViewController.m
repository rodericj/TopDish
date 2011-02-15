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
#define kpermission  [NSArray arrayWithObjects:@"user_about_me", nil]

@implementation SignInSignUpViewController
@synthesize signInButton = mSignInButton;
@synthesize signUpButton = mSignUpButton;
@synthesize fbLoginButton = mFbLoginButton;

-(void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;

	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];

}

/**
 * Show the authorization dialog.
 */
- (void)login {
	[[[AppModel instance] facebook] authorize:kpermission delegate:self];
}

-(void)logout{
	[[[AppModel instance] facebook] logout:self];
}

/**
 * Called on a login/logout button click.
 */
- (IBAction)fbButtonClick:(id)sender {
	if (self.fbLoginButton.isLoggedIn)
		[self logout];
	else
		[self login];
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
	[[[AppModel instance] facebook] setSessionDelegate:self];
	NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", nil];
	[[[AppModel instance] facebook] authorize:permissions delegate:self];

	
	//SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:@"SignUp" bundle:nil];
//	[self.navigationController pushViewController:signUp animated:YES];
//	[signUp release];	
}

-(void)viewDidAppear:(BOOL)animated
{		
	[super viewDidAppear:animated];
	NSLog(@"the view will appear. If we have the key, go to the account page");
	AppModel *a = [AppModel instance];
	NSLog(@"the api key is %@", [a.user objectForKey:keyforauthorizing]);
	if ([[AppModel instance].user objectForKey:keyforauthorizing] != nil || [[[AppModel instance] facebook] isSessionValid]) {
		AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
		[accountView release];
	}
}

- (void)fbDidLogin{	
	NSLog(@"user logged in");
	[self.fbLoginButton setIsLoggedIn:YES];
	[self.fbLoginButton updateImage];
	AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
	[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
	[accountView release];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
	NSLog(@"the user canceled");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
	NSLog(@"user logged out");
	[self.fbLoginButton updateImage];
}

-(void)dealloc
{	
	[super dealloc];
//	self.signInButton = nil;
//	self.signUpButton = nil;
}

@end
