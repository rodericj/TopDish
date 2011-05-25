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
@synthesize notNowLabel		= mNotNowLabel;
@synthesize googleLoginView	= mGoogleLoginView;


-(void)handleNotNowGesture:(UITapGestureRecognizer *)recognizer {
	[AppModel instance].userDelayedLogin = YES;
	[self.delegate noLoginNow];
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

/**
 *	Called when the google login button is clicked
 */
-(IBAction)googleButtonClick:(id)sender {
	NSLog(@"google login button clicked");
	
	self.googleLoginView.hidden = NO;
	
	//NSString *loginURL = [NSString stringWithFormat:@"%@/api/googleAuth?redirect=td://googleAuthResponse", NETWORKHOST];
	//NSURL *url = [NSURL URLWithString:loginURL];
	NSURL *url = [NSURL URLWithString:@"http://0519.topdish1.appspot.com/api/googleAuth?redirect=td://googleAuthResponse"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.googleLoginView loadRequest:request];
	
	
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
	
	UITapGestureRecognizer *notNotGesture = [[UITapGestureRecognizer alloc]
											initWithTarget:self action:@selector(handleNotNowGesture:)];
    [self.notNowLabel addGestureRecognizer:notNotGesture];
    [notNotGesture release];
	
	
	//setup the delegate notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appModelLoginComplete)
												 name:NSNotificationStringDoneLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appModelFacebookLoginComplete)
												 name:NSNotificationStringDoneFacebookLogin 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appModelLoginFailed)
												 name:NSNotificationStringFailedLogin 
											   object:nil];
}

#pragma mark -
#pragma mark Login steps and Hud stuff
-(void)appModelLoginFailed {
	DLog(@"facebook login failed");
	self.hud.labelText = @"Login Failed";
	self.hud.delegate = self;
	self.view.userInteractionEnabled = YES;
	
}
-(void)appModelFacebookLoginComplete {
	DLog(@"facebook login complete");
	self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.hud.labelText = @"Logging in with TopDish";
	self.hud.delegate = self;
	self.view.userInteractionEnabled = NO;
	[self.delegate facebookLoginComplete];
}

-(void)appModelLoginComplete {
	DLog(@"login complete");
	self.hud.labelText = @"Successfully logged in.";
	[self.hud hide:YES];
	[self.delegate loginComplete];
}

#pragma mark -
#pragma mark google login

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"webview failed to load %@", error);
	NSLog(@"%@", [[error userInfo] objectForKey:@"NSErrorFailingURLKey"]);
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webview webViewDidFinishLoad");
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webview webViewDidStartLoad");
}

-(void)viewDidAppear:(BOOL)animated {
	if ([[[AppModel instance] facebook] isSessionValid])
		[[AppModel instance] logoutWithDelegate:nil];
	
	self.fbLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	
	[self.fbLoginButton updateImage];
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.hud = nil;
	
	self.notNowLabel = nil;
	self.googleLoginView = nil;
	
    [super dealloc];
}


@end
