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
@synthesize delegate = mDelegate;

-(IBAction)notNowButtonPressed {
	[AppModel instance].userDelayedLogin = YES;
	[self.delegate notNowButtonPressed];
}

/**
 * Show the authorization dialog.
 */
- (void)login {
	[[[AppModel instance] facebook] authorize:kpermission delegate:[AppModel instance]];
	[self.delegate loginStarted];
}

-(void)logout{
	[[[AppModel instance] facebook] logout:[AppModel instance]];
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

+(LoginModalView *)viewControllerWithDelegate:(id<LoginModalViewDelegate>)delegate {
	LoginModalView *lmv = [[[LoginModalView alloc] initWithNibName:@"LoginModalView"
														   bundle:nil] autorelease];
	lmv.delegate = delegate;
	return lmv;
}

-(void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;
}

-(void)viewDidAppear:(BOOL)animated {
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
	
	//setup the delegate notifications
	[[NSNotificationCenter defaultCenter] addObserver:self.delegate
											 selector:@selector(loginComplete)
												 name:NSNotificationStringDoneLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self.delegate
											 selector:@selector(facebookLoginComplete)
												 name:NSNotificationStringDoneFacebookLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self.delegate
											 selector:@selector(loginFailed)
												 name:NSNotificationStringFailedLogin 
											   object:nil];
	
	//in the off chance that we've logged in since we loaded
	if (self.fbLoginButton.isLoggedIn)
		[self dismissModalViewControllerAnimated:YES];
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
