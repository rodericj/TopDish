//
//  RateADishViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RateADishViewController.h"
#import "constants.h"
#import "ASIFormDataRequest.h"
#import "AppModel.h"
#import "TopDishAppDelegate.h"
#import "JSON.h"
#import "FeedbackStringProcessor.h"
#import "UIImage+Resize.h"
#import "Logger.h"

#define kDishHeaderSection  0
#define kWouldYouRecommend  1
#define kDishCommentSection 2
#define kSubmitButtonCell   4
#define kFacebookCell       3

#define kNumberOfSections   5

@implementation RateADishViewController
@synthesize thisDish = mThisDish;

@synthesize dishHeaderCell = mDishHeaderCell;
@synthesize dishTitle = mDishTitle;
@synthesize restaurantTitle = mRestaurantTitle;
@synthesize dishImage = mDishImage;
@synthesize positiveReviews = mPositiveReviews;
@synthesize negativeReviews = mNegativeReviews;

@synthesize dishCommentCell = mDishCommentCell;
@synthesize dishComment = mDishComment;

@synthesize wouldYouCell = mWouldYouCell;
@synthesize yesImage = mYesImage;
@synthesize noImage = mNoImage;
@synthesize rating = mRating;

@synthesize pictureCell = mPictureCell;
@synthesize newPicture = mNewPicture;

@synthesize submitButtonCell = mSubmitButtonCell;
@synthesize submitButton = mSubmitButton;

@synthesize delegate = mDelegate;

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidLoad {
	[super viewDidLoad];
	self.restaurantTitle.text = [[self.thisDish restaurant] objName];
	self.restaurantTitle.textColor = kTopDishBlue;
	
	self.dishTitle.text = [self.thisDish objName];
	self.dishTitle.textColor = kTopDishBlue;

	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",[self.thisDish negReviews]];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",[self.thisDish posReviews]];
	
	self.noImage.hidden = YES;
	self.yesImage.hidden = YES;
	
	self.view.backgroundColor = kTopDishBackground;

    if ([self.thisDish.photoURL length] > 0)
        self.dishImage.image = [[AppModel instance] getImage:self.thisDish.photoURL size:85];
    else
        self.dishImage.image = [UIImage imageNamed:@"no_dish_img.png"];

}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",[self.thisDish negReviews]];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",[self.thisDish posReviews]];	

}

-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventRADViewDidAppear];

	[super viewDidAppear:animated];
	
	//if not logged in, pop out
	if (![[AppModel instance] isLoggedIn]) 
		[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kDishHeaderSection:
			return self.dishHeaderCell.bounds.size.height;
		case kDishCommentSection:
			return self.dishCommentCell.bounds.size.height;
		case kSubmitButtonCell:
			return self.submitButtonCell.bounds.size.height;
		default:
			break;
	}
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	
	switch (section) {
		case kDishCommentSection:
			return @"What did you think of this dish? (optional)";
		case kWouldYouRecommend:
			return @"Would you recommend this Dish?";
		default:
			break;
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kNumberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	UIView *backView;

	switch (indexPath.section) {
		case kDishHeaderSection:
			//we don't want this one to be clear for now
			return self.dishHeaderCell;
		case kDishCommentSection:
			cell = self.dishCommentCell;
			break;
		case kWouldYouRecommend:
			cell = self.wouldYouCell;
			backView = [[UIView alloc] initWithFrame:CGRectZero];
			cell.backgroundView = backView;
			[backView release];
			break;
		case kSubmitButtonCell:
			//if we are this far down, gotta remove keyboard :(
			[self.dishComment resignFirstResponder];
			cell = self.submitButtonCell;
			backView = [[UIView alloc] initWithFrame:CGRectZero];
			cell.backgroundView = backView;
			[backView release];
			break;
        case kFacebookCell: {
            UITableViewCell *fbCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                                             reuseIdentifier:nil] autorelease];
            
            UISwitch *fbSwitch = [[UISwitch alloc] init];
            [fbSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            BOOL isOn = [[[NSUserDefaults standardUserDefaults] objectForKey:FB_SWITCH_SETTING] boolValue];
            fbSwitch.on = isOn;
            fbCell.accessoryView = fbSwitch;
            [fbSwitch release];
            fbCell.textLabel.text = @"Post to Facebook?";
            fbCell.selectionStyle = UITableViewCellEditingStyleNone;
            return fbCell;
        }
            
		default:
			break;
	}
	
	// Configure the cell...
    return cell;
}
-(void)switchToggled:(UISwitch *)theSwitch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:theSwitch.on] forKey:FB_SWITCH_SETTING];    
	[defaults synchronize];
    
    //If the switch is on, but they aren't logged into facebook, log them in
    if (theSwitch.on && ![[AppModel instance].facebook isSessionValid]) {
        [[[AppModel instance] facebook] authorize:kpermission delegate:[AppModel instance]];
    }

}

#pragma mark -
#pragma mark keyboard delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

#pragma mark -
#pragma mark action sheet delegate
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

#pragma mark -
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
		[self.newPicture setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	DLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)takePicture{
	DLog(@"take a picture");
	
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

-(IBAction)yesButtonClicked {
    
    [Logger logEvent:kEventRDVote 
      withDictionary:[NSMutableDictionary dictionaryWithObject:@"Yes" forKey:@"yesno"]];
	self.noImage.hidden = YES;
	self.yesImage.hidden = NO;
	self.rating = 1;
	
	//just in case
	[self.dishComment resignFirstResponder];
	
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSubmitButtonCell]
						  atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
-(IBAction)noButtonClicked {
    [Logger logEvent:kEventRDVote 
      withDictionary:[NSMutableDictionary dictionaryWithObject:@"No" forKey:@"yesno"]];
    
	self.yesImage.hidden = YES;
	self.noImage.hidden = NO;
	self.rating = -1;
	
	//just in case
	[self.dishComment resignFirstResponder];
	
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kSubmitButtonCell]
						  atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
-(IBAction)submitRating {
    [Logger logEvent:kEventRDSubmitRating];
	[self.dishComment resignFirstResponder];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/rateDish"]];
        if (!self.rating) {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error Rating Dish" 
                                                                message:@"Please select Yes or No" 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertview show];
            [alertview release];
            return;
        }
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:self.dishComment.text forKey:@"comment"];
        [request setPostValue:[NSNumber numberWithInt:self.rating] forKey:@"direction"];
        [request setPostValue:[NSString stringWithFormat:@"%@", [self.thisDish dish_id]] forKey:@"dishId"];		
        [request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
        
        // Upload an NSData instance
        DLog(@"this is what we are sending for RATE a dish: url: %@\n, comment: %@\n, vote: %d\n, dish_id %@\n, apiKey: %@", 
             [url absoluteURL], 
             self.dishComment.text, 
             self.rating, 
             [self.thisDish dish_id],
             [[[AppModel instance] user] objectForKey:keyforauthorizing]); 
        
        [request setDelegate:self];
        [request startAsynchronous];
        mOutstandingRequests += 1;
        
        [self.navigationController setNavigationBarHidden: YES animated:YES];        
        mHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.tableView.userInteractionEnabled = NO;
        
        mHUD.mode = MBProgressHUDModeDeterminate;
        mHUD.progress = 0.1;
        mHUD.labelText = @"Rating dish";
        mHUD.delegate = self;
        
        
        //might as well send a picture if we've got it
        if (self.newPicture.image) {
            DLog(@"we have the dish id, calling add photo");
            NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
            DLog(@"the url for add photo is %@", url);
            request = [ASIFormDataRequest requestWithURL:url];
            [request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
            [request setPostValue:[NSString stringWithFormat:@"%d", [self.thisDish dish_id]] forKey:@"dishId"];
            [request setDelegate:self];
            [request startAsynchronous];
            mOutstandingRequests += 1;
            DLog(@"done calling add photo, time to call rateDish");
        }
    });
}

#pragma mark - Network and social stuff

-(void)facebookFeedPost {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:FB_SWITCH_SETTING] boolValue]) {
        [Logger logEvent:kEventRDFBPost];
        NSString *message = self.dishComment.text;
        NSString *imageUrl =  [self.thisDish.photoURL length] > 0 ? self.thisDish.photoURL :
        @"http://www.topdish.com/img/header/topdish_logo.png";
        NSString *linkUrl = [NSString stringWithFormat:
                             @"http://www.topdish.com/dishDetail.jsp?dishID=%@",
                             self.thisDish.dish_id];    
        
        NSString *feedItemName = [NSString stringWithFormat:@"Just rated %@ at %@", self.thisDish.objName, [self.thisDish.restaurant objName]];
        
        
        NSArray *obj = [NSArray arrayWithObjects:message, imageUrl, linkUrl, feedItemName, nil];
        NSArray *keys = [NSArray arrayWithObjects:@"message", @"picture", @"link", @"name", nil];
        
        // There are many other params you can use, check the API
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:obj forKeys:keys];
        
        [[AppModel instance].facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:nil];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	mOutstandingRequests -= 1;

	// Use when fetching text data
	NSString *responseString = [request responseString];
		
	DLog(@"response string for this dish or photo is %@", responseString);
	
	//Send feedback if broken
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		mHUD.labelText = message;
		[mHUD hide:YES afterDelay:3];
		return;
	}
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	[parser release];
	
	DLog(@"the dictionary should be a %@", responseAsDict);
	
	if([[responseAsDict objectForKey:@"rc"] intValue] != 0) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Rate Dish Failure"
													message:[responseAsDict objectForKey:@"message"]
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
		[a show];
		[a release];
		[mHUD hide:YES];
		return;
	}
	
	if ([responseAsDict objectForKey:@"photo"]) {
		self.thisDish.photoURL = [responseAsDict objectForKey:@"photo"];
		NSLog(@"the new photo is %@", self.thisDish.photoURL);
	}

	if ([responseAsDict objectForKey:@"url"])
	{
		mHUD.progress += .5;
		mHUD.labelText = @"uploading image";
		
		DLog(@"setting up the url");
		//NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [responseAsDict objectForKey:@"url"]]];
		DLog(@"the url for sending the photo is %@", url);
        
        if(self.newPicture.image.size.width > DEFAULTIMAGEDIMENSION || self.newPicture.image.size.height > DEFAULTIMAGEDIMENSION)
            self.newPicture.image = [self.newPicture.image resizedImage:CGSizeMake(384, 384) interpolationQuality:kCGInterpolationHigh];
        
		ASIFormDataRequest *imageRequest;
		imageRequest = [ASIFormDataRequest requestWithURL:url];
		[imageRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[imageRequest setData:UIImagePNGRepresentation(self.newPicture.image) forKey:@"photo"];
		[imageRequest setPostValue:[NSString stringWithFormat:@"%@", [self.thisDish dish_id]] forKey:@"dishId"];
		[imageRequest setDelegate:self];
		[imageRequest startAsynchronous];
		mOutstandingRequests += 1;
	}
	
	if(!mOutstandingRequests) {
		mHUD.progress = 1;
		mHUD.labelText = @"Dish Rated Successfully";
		mUploadSuccess = YES;
        
        if ([[AppModel instance].facebook isSessionValid]) {
            [self facebookFeedPost];
        }
		[mHUD hide:YES afterDelay:2]; 
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	DLog(@"error %@", [request error]);
	mHUD.labelText = @"Error while Uploading";
	[mHUD hide:YES afterDelay:2]; 
}

-(void)hudWasHidden {
	self.tableView.userInteractionEnabled = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];	
    if (mUploadSuccess) {
        [self.delegate doneRatingDish];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.thisDish = nil;
	self.dishHeaderCell = nil;
	self.dishTitle = nil;
	self.restaurantTitle = nil;
	self.dishImage = nil;
	
	self.positiveReviews = nil;
	self.negativeReviews = nil;
	
	self.dishCommentCell = nil;
	self.dishComment = nil;
	
	self.wouldYouCell = nil;
 	
	self.noImage = nil;
	self.yesImage = nil;
	
 	self.pictureCell = nil;
	self.newPicture = nil;
	
	self.submitButtonCell = nil;
	self.submitButton = nil;
	
	[super dealloc];
}


@end

