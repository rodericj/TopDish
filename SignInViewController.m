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

@implementation SignInViewController

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
	[[AppModel instance].user setObject:responseString forKey:keyforauthorizing];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

//see parent class for cancel clicked

@end
