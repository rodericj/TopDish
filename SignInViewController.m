//
//  SignInViewController.m
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "LoggedInLoggedOutGate.h"
#import "ASIHTTPRequest.h"
#import "constants.h"

@implementation SignInViewController

-(IBAction)submitClicked
{
	NSLog(@"username %@, password %@", 
		  self.userNameTextField.text, 
		  self.passwordTextField.text);
	
	//LoggedInLoggedOutGate *accountSettingsViewController = [[LoggedInLoggedOutGate alloc] init];
//	[self.navigationController popToRootViewControllerAnimated:YES];
//	[self.navigationController setViewControllers:[NSArray arrayWithObject:accountSettingsViewController]];

	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/login?email=%@", NETWORKHOST, self.userNameTextField.text]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUsername:self.userNameTextField.text];
	[request setPassword:self.passwordTextField.text];
	
	[request setDelegate:self];
	[request startAsynchronous];
	
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	// Use when fetching binary data
	NSData *responseData = [request responseData];

	NSLog(@"response string %@ \n and data %@\n %@", responseString, responseData, request );
}

//see parent class for cancel clicked

@end
