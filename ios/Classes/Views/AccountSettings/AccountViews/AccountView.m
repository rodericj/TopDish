//
//  AccountView.m
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountView.h"
#import "constants.h"
#import "FBLoginButton.h"
#import "Logger.h"

#define kNumberOfSections 2
#define kDishesReviewedSection 0
#define kFeedbackSection 1

@implementation AccountView

@synthesize userName = mUserName;
@synthesize userSince = mUserSince;
@synthesize tableHeader = mTableHeader;
@synthesize lifestyleTags = mLifestyleTags;
@synthesize imageRequest = mImageRequest;
@synthesize userImage = mUserImage;

@synthesize fBLoginButton = mFBLoginButton;
@synthesize logoutButton = mLogoutButton;

-(void)fetchFacebookMe {
	[[[AppModel instance] facebook] 
	 requestWithGraphPath:@"me" 
	 andDelegate:self];
}
#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
	self.tableView.tableHeaderView = self.tableHeader;
	self.userName.text = @"";
	self.userSince.text = @"";
	
	if ([[[AppModel instance] facebook] isSessionValid]) {
		//call the facebook api
		[self fetchFacebookMe];
		
		//add the logout button
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" 
										style:UIBarButtonItemStyleBordered
										target:self 
										action:@selector(logout)];
	}
	mPendingLogin = FALSE;
}

-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventAViewDidAppear];

	self.fBLoginButton.isLoggedIn = [[AppModel instance].facebook isSessionValid];
	[self.fBLoginButton updateImage];
	self.logoutButton.hidden = YES;
	self.fBLoginButton.hidden = YES;

	
	if ([[AppModel instance].facebook isSessionValid]) {
		[self fetchFacebookMe];
		NSLog(@"do some things");
		self.fBLoginButton.hidden = NO;

		self.logoutButton.hidden = YES;
	}
	else if ([[AppModel instance] isLoggedIn]) {
		//Make button look normal
		[self.fBLoginButton setTitle:@"Logout" forState:UIControlStateNormal];
		self.fBLoginButton.hidden = YES;
		self.logoutButton.hidden = NO;

	}
	else if(!mPendingLogin) {
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:YES];
		mPendingLogin = TRUE;
	}
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -
#pragma mark Logout

- (void)appModelDidLogout{
	self.fBLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	[self.fBLoginButton updateImage];
	self.userName.text = @"";
	self.userImage.image = [UIImage imageNamed:@"default_user_300x300.png"];
	self.userSince.text = @"";
	[self.tabBarController setSelectedIndex:0];
	
}

#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


	if (indexPath.section == kFeedbackSection) {
		NSLog(@"leave feedback");
		LeaveFeedbackViewController *feedback = [LeaveFeedbackViewController viewControllerWithDelegate:self];
		[self presentModalViewController:feedback animated:YES];
		
	}
	
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//Individual settings
	//dishes reviewed
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kDishesReviewedSection:
			return 0;
			break;
		case kFeedbackSection:
			return 1;
			break;
		default:
			break;
	}

	return 0;
}

-(UITableViewCell *) feedBackCell:(UITableViewCell *)cell {
	cell.textLabel.text = @"Leave Feedback";
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

-(UITableViewCell *) ratedDishesCells:(UITableViewCell *)cell {
	cell.textLabel.text = @"This is a dish rated";
	return cell;
}
	
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell...
	if (indexPath.section == kFeedbackSection) {
		return [self feedBackCell:cell];
	}
	
	if (indexPath.section == kDishesReviewedSection) {
		
	}
	
    return cell;
}

#pragma mark -
#pragma mark Facebook Request Delegate calls
/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request
{
	NSLog(@"fb request loading");
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"request did receive response");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
	DLog(@"did fail with error %@", error);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(NSDictionary *)result
{
	if([request.url hasSuffix:@"picture"]) {
		//do nothing
	}
	else{
		
		if ([result objectForKey:@"first_name"] && [result objectForKey:@"last_name"]) {
			
			self.userName.text = [NSString stringWithFormat:@"%@ %@",
								  [result objectForKey:@"first_name"],
								  [result objectForKey:@"last_name"]];
		}
		if ([result objectForKey:@"id"]) {
			self.imageRequest = [[[AppModel instance] facebook] 
								 requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", 
													   [result objectForKey:@"id"]] 
								 andDelegate:self];
		}
	}
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
	if (request == self.imageRequest){
		//set the user image to this data
		[self.userImage setImage:[UIImage imageWithData:data]];
	}
}

#pragma mark fb button
/**
 * Show the authorization dialog.
 */
- (void)login {
	[[[AppModel instance] facebook] authorize:kpermission delegate:self];
}

/**
 * Called on a login/logout button click.
 */
- (IBAction)fbButtonClick:(id)sender {
	if ([[AppModel instance] isLoggedIn])
		[[AppModel instance] logoutWithDelegate:self];
	else
		[self login];
}

- (IBAction)logoutButtonClick {
	[[AppModel instance] logoutWithDelegate:self];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	self.userName = nil;
	self.userSince = nil;
	self.tableHeader = nil;
	
	self.userImage = nil;
	self.imageRequest = nil;
	self.lifestyleTags = nil;
	self.fBLoginButton = nil;
	self.logoutButton = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark LeaveFeedbackViewControllerDelegate
-(void)feedbackCancelled {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)feedbackSubmitted {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark LoginModalViewDelegate
-(void)noLoginNow {
	mPendingLogin = NO;
	[self dismissModalViewControllerAnimated:YES];

	[self.tabBarController setSelectedIndex:0];
}

-(void)loginComplete {
	//This only works because the LoginModalView must be shown when we are logged out
	mPendingLogin = NO;
	[self dismissModalViewControllerAnimated:YES];
}

-(void)loginStarted {
}

-(void)facebookLoginComplete {
	[self fetchFacebookMe];
	self.fBLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	[self.fBLoginButton updateImage];
}

-(void)loginFailed {
}


@end

