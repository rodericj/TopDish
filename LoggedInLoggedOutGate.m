//
//  AccountSettingsViewController.m
//
//  Created by roderic campbell on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoggedInLoggedOutGate.h"
#import "SignInSignUpViewController.h"
#import "AccountView.h"
#import "AppModel.h"
#import "constants.h"

@implementation LoggedInLoggedOutGate


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSLog(@"setting the view for logged in logged out");

	if ([[AppModel instance].user objectForKey:keyforauthorizing] != nil || [[[AppModel instance] facebook] isSessionValid]) {
		AccountView *accountView = [[AccountView alloc] initWithNibName:@"AccountView" bundle:nil];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:accountView]];
		[accountView release];
	}
	else {
		SignInSignUpViewController *signInSignUp = [[SignInSignUpViewController alloc] initWithNibName:@"SignInSignUp" bundle:nil];
		[self.navigationController setViewControllers:[NSArray arrayWithObject:signInSignUp]];
		[signInSignUp release];
	}

}

@end
