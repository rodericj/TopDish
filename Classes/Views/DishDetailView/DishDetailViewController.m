//
//  DishDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DishDetailViewController.h"
#import "constants.h"
#import "JSON.h"
#import "RestaurantDetailViewController.h"
#import "ASIFormDataRequest.h"
#import "AppModel.h"
#import "CommentDetailViewController.h"
#import "FeedbackStringProcessor.h"
#import "UIImage+Resize.h"
#import "Logger.h"

#import "MWPhotoBrowser.h"

#define kImageSection 0
#define kDescriptionSection 1
#define kCommentsSection 2

#define kCommentHeight 14

#define kMoreDishesAtString @"More Dishes At"
@implementation DishDetailViewController

@synthesize thisDish = mThisDish;
@synthesize dishImageCell = mDishImageCell;
@synthesize dishImageView = mDishImageView;
@synthesize dishDescriptionCell = mDishDescriptionCell;
@synthesize dishDescriptionLabel = mDishDescriptionLabel;

@synthesize dishTagsLabel = mDishTagsLabel;

@synthesize negativeReviews = mNegativeReviews;
@synthesize positiveReviews = mPositiveReviews;

@synthesize dishNameLabel = mDishNameLabel;
@synthesize restaurantNameLabel = mRestaurantNameLabel;

@synthesize reviews = mReviews;
@synthesize responseData = mResponseData;

@synthesize tvCell = mTvCell;
@synthesize moreButton = mMoreButton;
@synthesize newPicture = mNewPicture;

@synthesize tableView = mTableView;

@synthesize interactionOverlay = mInteractionOverlay;

@synthesize flagView = mFlagView;

@synthesize hud = mHud;

@synthesize urlImageArray   = mImageUrlArray;

-(void)refreshFromNetwork {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", 
									   NETWORKHOST, 
									   self.thisDish.dish_id]];
	//Start up the networking
	DLog(@"the comments url is %@", url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == kDescriptionSection)
		return @"Description";
	if (section == kCommentsSection)
		return @"Comments";
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kImageSection:
			return 1;
			break;
		case kDescriptionSection:
			return 1;
			break;
		
		case kCommentsSection:
			return [self.reviews count];
		default:
			return 1;
			break;
	}
    return 0;
}
- (UITableViewCell *)commentsCellForIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"CommentsCellIdentifier";
	NSDictionary *commentItem = [self.reviews objectAtIndex:indexPath.row];
	NSString *comment = [commentItem objectForKey:@"comment"];
	NSString *creator = [commentItem objectForKey:@"creator"];
	NSNumber *voteDirection = [commentItem objectForKey:@"direction"];
	
	UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		//CommentCell comes from the file name CommentsCell.xib
		[[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
		cell = self.tvCell;
		//self.tvCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = comment;
	
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"-%@",creator];
	
	UIImageView *voteDirectionImage = (UIImageView *)[cell viewWithTag:3];
	if ([voteDirection intValue] == 1) {
		voteDirectionImage.image = [UIImage imageNamed:@"thumbsup.jpg"];
	}
	else {
		voteDirectionImage.image = [UIImage imageNamed:@"thumbsdown.jpg"];
	}
	
	return (UITableViewCell *)cell;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

	switch (indexPath.section) {
		case kImageSection:
			cell = self.dishImageCell;
			break;
			
		case kDescriptionSection:
			cell = self.dishDescriptionCell;
			break;

		case kCommentsSection:
			return [self commentsCellForIndexPath:indexPath];

		default:
			break;
	}
	// Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kCommentsSection) {
		NSDictionary *commentDict = [self.reviews objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:[CommentDetailViewController commentDetailViewWithCommentDict:commentDict] 
											 animated:YES];
	}
}
#pragma mark -
#pragma mark Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kImageSection) {
		return self.dishImageCell.bounds.size.height;
	}
	if (indexPath.section == kDescriptionSection) {
		return self.dishDescriptionCell.bounds.size.height;
	}
	return 100;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

-(void)showPhotoViewer {
    [Logger logEvent:kEventDDTapPhoto];
    NSLog(@"show photo viewer");
    if ([self.urlImageArray count]) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        for (NSString *url in self.urlImageArray) {
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
        }
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];
        //[browser setInitialPageIndex:0]; // Can be changed if desired
        [self.navigationController pushViewController:browser animated:YES];
        [browser release];
        [photos release];

    }
}


-(void) setUpView {
    
    if( [self.thisDish.photoURL length] > 0 ){
		if (![[AppModel instance] doesCacheItemExist:self.thisDish.photoURL size:290]) {
			dispatch_queue_t downloadQueue = dispatch_queue_create("com.topdish.imagedownload", NULL);
			
			//On background thread, download the image synchronously.
			dispatch_async(downloadQueue, ^{
				//Set up URL and download image (all in the background)
				[[AppModel instance] getImage:self.thisDish.photoURL size:290];
				
				//On the main thread, update the appropriate cell and the core data object
				dispatch_async(dispatch_get_main_queue(), ^{
                    //scary potential recursion?
                    [self setUpView];
                    dispatch_release(downloadQueue);
				});
			});
		}
		else {
			self.dishImageView.image = [[AppModel instance] getImage:self.thisDish.photoURL size:290];
            UITapGestureRecognizer *tapPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhotoViewer)];
            [self.dishImageView addGestureRecognizer:tapPhoto];
            self.dishImageView.userInteractionEnabled = YES;
            [tapPhoto release];
		}		
		
	}	
	else {
		self.dishImageView.image = [UIImage imageNamed:@"no_dish_img.jpg"];
        UITapGestureRecognizer *tapPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedEmptyImage)];
        [self.dishImageView addGestureRecognizer:tapPhoto];
        self.dishImageView.userInteractionEnabled = YES;
        [tapPhoto release];
    
    }
	[self.dishDescriptionLabel setText:self.thisDish.dish_description];
	
	AppModel *app = [AppModel instance];
	Dish *d = self.thisDish;
	NSMutableString *tagString = [[NSMutableString alloc] initWithCapacity:20];
	[tagString appendString:[app tagNameForTagId:d.cuisineType] ? [app tagNameForTagId:d.cuisineType] : @""];
	[tagString appendString:@" "];
	[tagString appendString:[app tagNameForTagId:d.mealType] ? [app tagNameForTagId:d.mealType] : @""];
	[tagString appendString:@" "];
	[tagString appendString:[app tagNameForTagId:d.price] ? [app tagNameForTagId:d.price] : @""];
	[tagString appendString:@" "];
	[tagString appendString:[app tagNameForTagId:d.lifestyleType] ? [app tagNameForTagId:d.lifestyleType] : @""];
	
	self.dishTagsLabel.text = tagString;
	[tagString release];
	
	[self.dishNameLabel setText:self.thisDish.objName];
	[self.dishNameLabel setTextColor:kTopDishBlue];
	
	[self.restaurantNameLabel setText:self.thisDish.restaurant.objName];
	[self.restaurantNameLabel setTextColor:kTopDishBlue];
	
	UITapGestureRecognizer *restaurantTouchGesture = [[UITapGestureRecognizer alloc]
													  initWithTarget:self action:@selector(tapRestaurantText)];
    [self.restaurantNameLabel addGestureRecognizer:restaurantTouchGesture];
    [restaurantTouchGesture release];
	
	
	NSString *buttonTitle = @"More Dishes Here";
	
	[self.moreButton setTitle:buttonTitle
					 forState:UIControlStateNormal];
}
- (void)viewDidLoad {
		
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:self.interactionOverlay.frame] autorelease];
	[self setUpView];
	
	[self refreshFromNetwork];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = kTopDishBlue;
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",self.thisDish.negReviews];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",self.thisDish.posReviews];	
}

-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventDDViewDidAppear];

	[UIView beginAnimations:@"animateOverlay" context:NULL]; // Begin animation
	[self.interactionOverlay setFrame:CGRectOffset([self.interactionOverlay frame], 
												   0, 
												   -self.interactionOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	
}
-(void)viewWillDisappear:(BOOL)animated {
	[UIView beginAnimations:@"animateOverlay" context:NULL]; // Begin animation
	[self.interactionOverlay setFrame:CGRectOffset([self.interactionOverlay frame], 
												   0, 
												   self.interactionOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	
}

-(void)releaseWhenViewUnloads {
    self.urlImageArray = nil;
	self.thisDish = nil;
	self.dishImageCell = nil;
	self.dishImageView = nil;
	self.negativeReviews = nil;
	self.positiveReviews = nil;
	
	self.dishDescriptionCell = nil;
	self.dishDescriptionLabel = nil;
	
	self.dishNameLabel = nil;
	self.restaurantNameLabel = nil;
	
	self.reviews = nil;
	self.responseData = nil;
	
	self.tvCell = nil;
	self.moreButton = nil;
	
	self.hud = nil;
	self.tableView = nil;
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[self releaseWhenViewUnloads];
}

- (void)dealloc {
	[self releaseWhenViewUnloads];	
    [super dealloc];
}

#pragma mark -
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	DLog(@"didFinishLoading dishDetailViewController start");
	NSString *responseText = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSError *error;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
    [responseText release];
	[parser release];

	DLog(@"responseAsDictionary %@", responseAsDictionary);		
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		return;
	}

	NSArray *responseAsArray = [responseAsDictionary objectForKey:@"dishes"];
	NSDictionary *thisDishDetailDictionary = [responseAsArray objectAtIndex:0];
	//DLog(@"%@", thisDishDetailDictionary);
	if(self.reviews == nil){
		self.reviews = [NSArray alloc];
	}
	
	self.reviews = [[thisDishDetailDictionary objectForKey:@"reviews"] copy];
	
	self.thisDish.posReviews = [thisDishDetailDictionary objectForKey:@"posReviews"];
	self.thisDish.negReviews = [thisDishDetailDictionary objectForKey:@"negReviews"];
	
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",self.thisDish.negReviews];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",self.thisDish.posReviews];

    self.urlImageArray = [thisDishDetailDictionary objectForKey:@"photoURL"];
    if ([self.urlImageArray count] && ![self.thisDish.photoURL isEqualToString:[self.urlImageArray objectAtIndex:0]]) {
        self.thisDish.photoURL = [self.urlImageArray objectAtIndex:0];
    }
	self.responseData = nil;
    [self setUpView];
	[self.tableView reloadData];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	DLog(@"didFinishLoading dishDetailViewController end");

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	DLog(@"This is the dish detail error %@", error);
	
	//TODO when the server is in a bit better shape I'll have to 
	//remove this default call as well as the hard coded data
	//[self connectionDidFinishLoading:connection];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];	
#endif
	self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(self.responseData == nil){
		self.responseData =  [NSMutableData dataWithData:data];
	}
	else {
		[self.responseData appendData:data];
		DLog(@"a ha!, the response text was not null, which means we may be missing some data");
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	DLog(@"error %@", [request error]);
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	DLog(@"response string for any of these calls %@", responseString);
	
	if ([[[request.url pathComponents] objectAtIndex:[[request.url pathComponents] count] - 1] isEqualToString:@"flagDish"] ) {
		//TODO handle the flag successfully or unsuccessfully happening
		NSLog(@"this is a flag dish call, do something different");
		
		UIAlertView *a;
		NSString *message;
		if (request.responseStatusCode == 200)
			message = @"Your request flag this Dish was successful. Thanks for making TopDish great!";
		else  {
			message = @"Your request to flag this Dish Failed. Please try later";     
			self.flagView.hidden = NO;
		}
		
		a = [[UIAlertView alloc] initWithTitle:@"Feedback" 
									   message:message
									  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[a show];
		[a release];
		return;
	}
	
	//Send feedback if broken
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		self.hud.labelText = message;
		[self.hud hide:YES afterDelay:3];
		return;
	}
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	[parser release];
	
	DLog(@"the dictionary should be a %@", responseAsDict);
	
	ASIFormDataRequest *newRequest;
	
	if ([[responseAsDict objectForKey:@"rc"] intValue]) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Request Failed" 
															message:[responseAsDict objectForKey:@"message"]
														   delegate:self 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		return;
	}
	if ([responseAsDict objectForKey:@"url"]) {
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [responseAsDict objectForKey:@"url"]]];
		DLog(@"the url for sending the photo is %@", url);
		
        if(self.newPicture.size.width > DEFAULTIMAGEDIMENSION || self.newPicture.size.height > DEFAULTIMAGEDIMENSION)
            self.newPicture = [self.newPicture resizedImage:CGSizeMake(DEFAULTIMAGEDIMENSION, DEFAULTIMAGEDIMENSION) interpolationQuality:kCGInterpolationHigh];

		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setData:UIImagePNGRepresentation(self.newPicture) forKey:@"photo"];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [self.thisDish.dish_id intValue]] forKey:@"dishId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		return;
		
	}
	self.hud.labelText = @"Successfully submitted the image";
	[self.hud hide:YES afterDelay:3];
	self.view.userInteractionEnabled = YES;
    [self refreshFromNetwork];
	DLog(@"done!");
}

-(void)hudWasHidden {
    [self.navigationController setNavigationBarHidden: NO animated:YES];
}

#pragma mark -
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//self.dishImageFromPicker = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
		self.newPicture = [info objectForKey:@"UIImagePickerControllerEditedImage"];
		
        [self.navigationController setNavigationBarHidden: YES animated:YES]; 
		self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		self.view.userInteractionEnabled = NO;

		self.hud.labelText = @"Uploading photo...";
		self.hud.delegate = self;
		self.hud.mode = MBProgressHUDModeIndeterminate;
		
		
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
		ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [self.thisDish.dish_id intValue]] forKey:@"dishId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		DLog(@"done calling add photo, time to call rateDish");
	}
	[self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	DLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
        //cancelled
        return;
    }
	
	DLog(@"show the picture thing");
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setAllowsEditing:YES];
	
	if(buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		//then push the imagepicker
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
		[imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
	}
	else {
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	[self presentModalViewController:imagePicker animated:YES]; 
}


-(void)startCameraFlow {
    if ([[AppModel instance] isLoggedIn] ) {
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil//@"Camera or Library?" 
																 delegate:self 
														cancelButtonTitle:nil 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet addButtonWithTitle:@"Take a picture"];
		[actionSheet addButtonWithTitle:@"Choose from Library"];
		actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
		[actionSheet showInView:self.navigationController.tabBarController.view];
		[actionSheet release];
	}
	else {
		mPostLoginAction = @selector(takePicture);
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:YES];
	}

}

-(void)tappedEmptyImage {
    [Logger logEvent:kEventDDTapEmptyPhoto];
    [self startCameraFlow];
    
}
#pragma mark -
#pragma mark IBActions
-(IBAction)takePicture
{
    [Logger logEvent:kEventDDTapPictureButton];
    [self startCameraFlow];
}

-(IBAction)pushRateDishController {
    [Logger logEvent:kEventDDTapRateDish];
	if ([[AppModel instance] isLoggedIn]) {
		RateADishViewController *rateDish = 
		[[RateADishViewController alloc] initWithNibName:@"RateADishViewController" 
												  bundle:nil];
		[rateDish setThisDish:self.thisDish];
		[rateDish setDelegate:self];
		[self.navigationController pushViewController:rateDish 
											 animated:YES];
		
		[rateDish release];
	}
	else {
		mPostLoginAction = @selector(pushRateDishController);
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:YES];
	}
}

-(void)pushRestaurantDetailController {
    //should be logged already
    
	RestaurantDetailViewController *restaurantController = [RestaurantDetailViewController restaurantDetailViewWithRestaurant:self.thisDish.restaurant];
	[self.navigationController pushViewController:restaurantController animated:YES];
}

-(void)tapRestaurantText {
    [Logger logEvent:kEventDDTapRestaurantText];
	[self pushRestaurantDetailController];

}
-(IBAction)tapRestaurantButton {
    [Logger logEvent:kEventDDTapMoreDishes];
	[self pushRestaurantDetailController];
}

-(IBAction)flagThisDish{
    [Logger logEvent:kEventDDTapFlagRestaurant];

	DLog(@"flagging this dish");
	self.flagView.hidden = YES;
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/flagDish"]];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.thisDish.dish_id forKey:@"dishId"];
	
	//inaccurate 0  spam  1 inappropriate 2
	[request setPostValue:@"0" forKey:@"type"];
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	
	[request setDelegate:self];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark LoginModalViewDelegate
-(void)loginFailed {
	DLog(@"dish detail login failed");
}

-(void)loginStarted {
	DLog(@"the login started");
}

-(void)loginComplete {
	DLog(@"the login is fully completed");
	[self dismissModalViewControllerAnimated:YES];
	[self performSelector:mPostLoginAction];
}

-(void)noLoginNow {
	DLog(@"do nothing but just dismiss the modal");
	[self dismissModalViewControllerAnimated:YES];
}

-(void)facebookLoginComplete {
	DLog(@"ok, the facebook login is complete for the DishDetailViewController");
}

#pragma mark -
#pragma mark RateDishProtocolDelegate
-(void)doneRatingDish {
    [Logger logEvent:kEventDDDoneRatingDish];

	[self refreshFromNetwork];
	[self.navigationController popViewControllerAnimated:YES];
}

@end

