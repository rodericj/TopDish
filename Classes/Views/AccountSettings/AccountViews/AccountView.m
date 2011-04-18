//
//  AccountView.m
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountView.h"
#import "constants.h"
#import "AppModel.h"
#import "FBLoginButton.h"

#define kNumberOfSections 1
#define kDishesReviewedSection 0

@implementation AccountView

@synthesize userName = mUserName;
@synthesize userSince = mUserSince;
@synthesize tableHeader = mTableHeader;
@synthesize lifestyleTags = mLifestyleTags;
@synthesize imageRequest = mImageRequest;
@synthesize userImage = mUserImage;
@synthesize fBLoginButton = mFBLoginButton;

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
	self.fBLoginButton.isLoggedIn = [[[AppModel instance] facebook] isSessionValid];
	[self.fBLoginButton updateImage];

	if ([[AppModel instance] isLoggedIn]) {
		NSLog(@"do some things");
	}
	else if(!mPendingLogin)
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:YES];
	mPendingLogin = TRUE;
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark -
#pragma mark Logout

- (void)fbDidLogout{
	[[AppModel instance] logout];
	[self.tabBarController setSelectedIndex:0];
}

#pragma mark -
#pragma mark Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kDishesReviewedSection:
			return @"Dishes Reviewed";
		default:
			return nil;
	}
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	switch (indexPath.section) {
		case kDishesReviewedSection:
			return 20;
		default:
			break;
	}
	return 0;
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
		default:
			break;
	}

	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell addSubview:self.tableHeader];
    // Configure the cell...
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
	if (request == self.imageRequest) {
		//do nothing
	}
	else{
		DLog(@"did load %@", result);

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
	if (self.fBLoginButton.isLoggedIn)
		[[[AppModel instance] facebook] logout:self];
	else
		[self login];
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
	
	[super dealloc];
}

#pragma mark -
#pragma mark LoginModalViewDelegate
-(void)notNowButtonPressed {
	mPendingLogin = NO;
	[self dismissModalViewControllerAnimated:YES];
	[self.tabBarController setSelectedIndex:0];
}

-(void)loginComplete {

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

