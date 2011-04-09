//
//  LoginModalView.m
//  TopDish
//
//  Created by roderic campbell on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginModalView.h"
#import "AppModel.h"
#import "constants.h"

@implementation LoginModalView

@synthesize fbLoginButton = mFbLoginButton;

-(IBAction)okButtonPressed {
	[AppModel instance].userDelayedLogin = YES;
	[self dismissModalViewControllerAnimated:YES];

}

/**
 * Show the authorization dialog.
 */
- (void)login {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginComplete:)
												 name:NSNotificationStringDoneLogin 
											   object:nil];
	[[[AppModel instance] facebook] authorize:kpermission delegate:[AppModel instance]];
}

-(void)logout{
	[[[AppModel instance] facebook] logout:[AppModel instance]];
}

-(void)loginComplete:(NSNotification *)notification {
	NSLog(@"the notification is finished");
	[self dismissModalViewControllerAnimated:YES];
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

-(void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;
	
}

-(void)viewDidAppear:(BOOL)animated {
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
