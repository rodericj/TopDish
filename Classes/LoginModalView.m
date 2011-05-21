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

@synthesize fbLoginButton	= mFbLoginButton;
@synthesize delegate		= mDelegate;
@synthesize	hud				= mHud;

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
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginComplete)
												 name:NSNotificationStringDoneLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(facebookLoginComplete)
												 name:NSNotificationStringDoneFacebookLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loginFailed)
												 name:NSNotificationStringFailedLogin 
											   object:nil];
}

#pragma mark -
#pragma mark Login steps and Hud stuff
-(void)loginFailed {
	DLog(@"facebook login failed");
	self.hud.labelText = @"Login Failed";
	self.hud.delegate = self;
	self.view.userInteractionEnabled = YES;
	
}
-(void)facebookLoginComplete {
	DLog(@"facebook login complete");
	self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.hud.labelText = @"Logging in with TopDish";
	self.hud.delegate = self;
	self.view.userInteractionEnabled = NO;
}

-(void)loginComplete {
	DLog(@"login complete");
	self.hud.labelText = @"Successfully logged in.";
	[self.hud hide:YES];
}

-(void)viewDidAppear:(BOOL)animated {
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
	
	//in the off chance that we've logged in since we loaded
	if (self.fbLoginButton.isLoggedIn)
		[[AppModel instance] logoutWithDelegate:nil];
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.hud = nil;
    [super dealloc];
}


@end
