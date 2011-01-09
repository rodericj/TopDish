//
//  AccountSettingsViewController.m
//
//  Created by roderic campbell on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "SignInSignUpViewController.h"

@implementation AccountSettingsViewController

-(BOOL)isLoggedIn
{
	return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([self isLoggedIn]) {

	}
	else {
		SignInSignUpViewController *signInSignUp = [[SignInSignUpViewController alloc] initWithNibName:@"SignInSignUp" bundle:nil];
		[self.navigationController pushViewController:signInSignUp animated:YES];
		[signInSignUp release];
	}

}

@end
