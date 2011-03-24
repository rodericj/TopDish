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
@synthesize fbLoginButton = mFbLoginButton;

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#pragma mark -
#pragma mark view lifetime stuff
-(void) viewDidLoad {
	[super viewDidLoad];
	Facebook *facebook = [[AppModel instance] facebook];
	if ([facebook isSessionValid]) {
		//call the facebook api
		[facebook requestWithGraphPath:@"me" andDelegate:self];
		
		//add the logout button
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
																				  style:UIBarButtonItemStyleBordered
																				 target:self 
																				 action:@selector(logout)];
		
	}
	else {
		[facebook authorize:kpermission delegate:self];
	}

	
	self.view.backgroundColor = kTopDishBackground;
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
}

-(void)viewDidAppear:(BOOL)animated
{		
	[super viewDidAppear:animated];
	NSLog(@"the view will appear. If we have the key, go to the account page");
	NSLog(@"the api key is %@", [[AppModel instance].user objectForKey:keyforauthorizing]);
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

#pragma mark -
#pragma mark IBAction
-(IBAction)signUpClicked
{
	//[[[AppModel instance] facebook] setSessionDelegate:[AppModel instance]];
	NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", nil];
	[[[AppModel instance] facebook] authorize:permissions delegate:self];
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

#pragma mark -
#pragma mark FBcallbacks
- (void)fbDidLogin{	
	NSLog(@"user logged in");
	[self.fbLoginButton setIsLoggedIn:YES];
	[self.fbLoginButton updateImage];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/facebookLogin", NETWORKHOST]];
	NSLog(@"[[AppModel instance] facebook].accessToken %@\n the url we are hitting is %@", 
		 [[AppModel instance] facebook].accessToken, url);
	
	//Call the topdish server to log in
	mTopDishFBLoginRequest = [ASIFormDataRequest requestWithURL:url];
	[mTopDishFBLoginRequest setPostValue:[[AppModel instance] facebook].accessToken forKey:@"facebookApiKey"];
	[mTopDishFBLoginRequest setAllowCompressedResponse:NO];
	[mTopDishFBLoginRequest setDelegate:self];	
	[mTopDishFBLoginRequest startAsynchronous];
	
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


#pragma mark -
#pragma mark network callback 
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching binary data
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSString *responseString = [request responseString];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	[parser release];
	NSLog(@"the dictionary should be a %@", responseAsDict);

	if (request == mTopDishFBLoginRequest) {
		//responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
		NSLog(@"handle the facebook authentication stuff %@", responseString);
		if ([[responseAsDict objectForKey:@"rc"] intValue] == 1) {
			//response returned with an error. Lets see what we got
			NSLog(@"response from TD Server %@", responseAsDict);
		}
		else {
			[responseAsDict objectForKey:keyforauthorizing];
			[[AppModel instance].user setObject:[responseAsDict objectForKey:keyforauthorizing] forKey:keyforauthorizing];
			[self.navigationController popToRootViewControllerAnimated:YES];
			
			LoggedInLoggedOutGate *gate = [[LoggedInLoggedOutGate alloc] init];
			//[self.navigationController pushViewController:signIn animated:NO];
			[self.navigationController setViewControllers:[NSArray arrayWithObject:gate]];
			[gate release];
		}

	}
	else 
		NSLog(@"not really sure what we just returned %@", responseAsDict);
}

//see parent class for cancel clicked

@end
