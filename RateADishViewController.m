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

#define kDishHeaderSection 0
#define kDishCommentSection 1
#define kWouldYouRecommend 2
#define kPictureCell 3
#define kSubmitButtonCell 4

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

	self.dishImage.image = [UIImage imageWithData:[self.thisDish imageData]];
	
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",[self.thisDish negReviews]];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",[self.thisDish posReviews]];	
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[AppModel instance].user objectForKey:keyforauthorizing] == nil)
		[[(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:kAccountsTab];

}
#pragma mark -
#pragma mark Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kDishHeaderSection:
			return self.dishHeaderCell.bounds.size.height;
		case kDishCommentSection:
			return self.dishCommentCell.bounds.size.height;
		case kPictureCell:
			return self.pictureCell.bounds.size.height;
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
			return @"Additional Food For Thought?";
		case kWouldYouRecommend:
			return @"Would you recommend this Dish?";
		case kPictureCell:
			return @"Upload a Picture";
			
		default:
			break;
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
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
    
	switch (indexPath.section) {
		case kDishHeaderSection:
			//we don't want this one to be clear for now
			return self.dishHeaderCell;
		case kDishCommentSection:
			cell = self.dishCommentCell;
			break;
		case kWouldYouRecommend:
			cell = self.wouldYouCell;
			break;
		case kPictureCell:
			cell = self.pictureCell;
			break;
		case kSubmitButtonCell:
			cell = self.submitButtonCell;
			break;
		default:
			break;
	}
	
	// Configure the cell...
    UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	backView.backgroundColor = [UIColor clearColor];
	cell.backgroundView = backView;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//self.dishImageFromPicker = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
		[self.newPicture setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	NSLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
	//[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IBActions

-(IBAction)takePicture{
	NSLog(@"show the picture thing");
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setAllowsEditing:YES];
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		//then push the imagepicker
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
		[imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];

		[imagePicker setCameraOverlayView:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	}
	else {
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	[self presentModalViewController:imagePicker animated:YES]; 
	
	
}
-(IBAction)yesButtonClicked {
	self.noImage.hidden = YES;
	self.yesImage.hidden = NO;
	self.rating = 1;
}
-(IBAction)noButtonClicked {
	self.yesImage.hidden = YES;
	self.noImage.hidden = NO;
	self.rating = -1;
}

-(IBAction)submitRating {
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
	//if (self.newPicture.image)
	//	[request setData:UIImagePNGRepresentation(self.newPicture.image) forKey:@"photo"];
	
	NSLog(@"this is what we are sending for RATE a dish: url: %@\n, comment: %@\n, vote: %d\n, dish_id %@\n, apiKey: %@", 
		  [url absoluteURL], 
		  self.dishComment.text, 
		  self.rating, 
		  [self.thisDish dish_id],
		  [[[AppModel instance] user] objectForKey:keyforauthorizing]); 
	
	[request setDelegate:self];
	[request startAsynchronous];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	
	NSLog(@"response string %@", responseString);
	[self.navigationController popViewControllerAnimated:YES];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"error %@", error);
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
    [super dealloc];
	//self.thisDish = nil;
//	self.dishHeaderCell = nil;
//	self.dishTitle = nil;
//	self.restaurantTitle = nil;
//	self.dishImage = nil;
//	
//	self.dishCommentCell = nil;
//	self.dishComment = nil;
//	
//	self.wouldYouCell = nil;
// 	self.wouldYou = nil;
//	
// 	self.pictureCell = nil;
//	self.newPicture = nil;
//	
//	self.submitButtonCell = nil;
//	self.submitButton = nil;
}


@end

