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
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/facebookLogin", NETWORKHOST]];
	NSLog(@"[[AppModel instance] facebook].accessToken %@", [[AppModel instance] facebook].accessToken);
	//Call the topdish server to log in
	mTopDishFBLoginRequest = [ASIFormDataRequest requestWithURL:url];
	[mTopDishFBLoginRequest setPostValue:[[AppModel instance] facebook].accessToken forKey:@"facebookApiKey"];
	[mTopDishFBLoginRequest setAllowCompressedResponse:NO];
	[mTopDishFBLoginRequest setDelegate:self];
	[mTopDishFBLoginRequest startSynchronous];
	
	[mTopDishFBLoginRequest startAsynchronous];
	
	//AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
//	[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
//	[accountView release];
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
	[self.fbLoginButton setIsLoggedIn:YES];
	[self.fbLoginButton updateImage];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching binary data
	NSString *responseText = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
	NSLog(@"response Text %@", responseText);
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	NSLog(@"dictionary %@", responseAsDictionary);
	//NSString *responseText = [[NSString alloc] initWithData:[request rawResponseData] encoding:NSUTF8StringEncoding];
	NSLog(@"responseText = %@", responseText);
	NSLog(@"request to get the auth key");
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	if (request == mTopDishFBLoginRequest) {
		responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSArray *m = (NSArray *)[request rawResponseData];
		NSLog(@"m is %@", m);
		NSLog(@"handle the facebook authentication stuff %@", responseString);
		for (NSDictionary *responseItem in [request rawResponseData]) {
			if ([[responseItem objectForKey:@"key"] isEqualToString:@"facebookApiKey"]) {
				[[AppModel instance].user setObject:[responseItem objectForKey:@"value" forKey:keyforauthorizing]];
				[mTopDishFBLoginRequest release];
			}
			
		}	

	}
	else {
		/*
		 NSMutableDictionary *query = [NSMutableDictionary dictionary];
		 NSString *username = "username";
		 [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
		 [query setObject:username forKey:(id)kSecAttrAccount];
		 [query setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
		 [query setObject:[self.userNameTextField.text dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
		 
		 OSStatus error = SecItemAdd((CFDictionaryRef)query, NULL);
		 */
		NSString *responseString = [request responseString];
		[[AppModel instance].user setObject:responseString forKey:keyforauthorizing];
		[self.navigationController popToRootViewControllerAnimated:YES];
		
		LoggedInLoggedOutGate *gate = [[LoggedInLoggedOutGate alloc] init];
		//[self.navigationController pushViewController:signIn animated:NO];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:gate]];
		[gate release];
		
		
	}
}

//see parent class for cancel clicked

@end
