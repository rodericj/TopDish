//
//  SignInViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "ASIHTTPRequest.h"
#import "constants.h"
#import "AppModel.h"
#import "AccountView.h"

@implementation SignInViewController
@synthesize signUpButton = mSignUpButton;
@synthesize fbLoginButton = mFbLoginButton;

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kpermission  [NSArray arrayWithObjects:@"user_about_me", nil]

-(void) viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
	
	
	
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
- (void)fbDidLogin{	
	NSLog(@"user logged in");
	[self.fbLoginButton setIsLoggedIn:YES];
	[self.fbLoginButton updateImage];
	AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
	[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
	[accountView release];
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
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[self animateTextField: textField up: YES];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	self.view.frame = CGRectMake(self.view.frame.origin.x, SIGNIN_Y_COORD, self.view.frame.size.width, self.view.frame.size.height);
	[UIView commitAnimations];
}
-(IBAction)submitClicked
{	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/login?email=%@", NETWORKHOST, self.userNameTextField.text]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	//[request setUsername:self.userNameTextField.text];
//	[request setPassword:self.passwordTextField.text];
	
	NSLog(@"username %@, password %@ \n%@", 
		  self.userNameTextField.text, 
		  self.passwordTextField.text,
		  [url absoluteURL]);
	
	[request setDelegate:self];
	[request startAsynchronous];
	
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
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	NSLog(@"response string %@", responseString);
	
	if ([responseString isEqualToString:@"Nothing to see here."]) {
		NSLog(@"error, incorrect password");
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Login Failed" 
															message:@"Your user username or password are incorrect" 
														   delegate:self 
												  cancelButtonTitle:@"OK"
												   otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		return;
	}
	/*
	NSMutableDictionary *query = [NSMutableDictionary dictionary];
	NSString *username = "username";
	[query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	[query setObject:username forKey:(id)kSecAttrAccount];
	[query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
	[query setObject:[self.userNameTextField.text dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
	
	OSStatus error = SecItemAdd((CFDictionaryRef)query, NULL);
	 */
	
	[[AppModel instance].user setObject:responseString forKey:keyforauthorizing];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

//see parent class for cancel clicked

@end
