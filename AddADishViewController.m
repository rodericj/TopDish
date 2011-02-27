//
//  AddADishViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddADishViewController.h"
#import "constants.h"
#import "ASIFormDataRequest.h"
#import "DishOptionPickerTableViewController.h"
#import "AppModel.h"
#import "TopDishAppDelegate.h"
#import "JSON.h"

#define kRestaurantSection 0
#define kDishNameSection 1
#define kDishTagSection 2
#define kWouldYouRecommendSection 3
#define kUploadPictureSection 4
#define kAdditionalDetailsSection 5

#define kMealTypeRow 0
#define kPriceTypeRow 1

#define kAddDishViewTextColor [UIColor colorWithRed:.3019 green:.2588 blue:.1686 alpha:1]

@implementation AddADishViewController

@synthesize restaurant = mRestaurant;
@synthesize managedObjectContext=managedObjectContext_;

@synthesize restaurantCell = mRestaurantCell;
@synthesize restaurantTitle = mRestaurantTitle;

@synthesize dishNameCell = mDishNameCell;
@synthesize dishTitle = mDishTitle;

@synthesize wouldYouCell = mWouldYouCell;
@synthesize yesImage = mYesImage;
@synthesize noImage = mNoImage;
@synthesize rating = mRating;

@synthesize uploadCell = mUploadCell;
@synthesize newPicture = mNewPicture;

@synthesize additionalDetailsCell = mAdditionalDetailsCell;
@synthesize additionalDetailsTextView = mAdditionalDetailsTextView;
@synthesize commentTextView = mCommentTextView;

@synthesize submitButton = mSubmitButton;

@synthesize selectedMealType = mSelectedMealType;
@synthesize selectedPriceType = mSelectedPriceType;
@synthesize currentSelection = mCurrentSelection;

@synthesize dishId = mDishId;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
	self.restaurantTitle.text = [self.restaurant objName];
	pointer = malloc(sizeof(int));
	*pointer = 0;
}



- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"and the pointer is %d", *pointer);
	if (self.currentSelection == kMealTypeRow)
	{
		self.selectedMealType = *pointer;
		NSArray *mealTags = [[AppModel instance] mealTypeTags];
		self.selectedMealType = [[[mealTags objectAtIndex:*pointer] objectForKey:@"id"] intValue];
	}
	else
	{
		NSArray *priceTags = [[AppModel instance] priceTags];
		NSLog(@"priceTags is %@", [priceTags objectAtIndex:*pointer]);
		NSLog(@"the id is %@", [[priceTags objectAtIndex:*pointer] objectForKey:@"id"]);
		self.selectedPriceType = [[[priceTags objectAtIndex:*pointer] objectForKey:@"id"] intValue];
	}		

    [super viewWillAppear:animated];
	[self.tableView beginUpdates];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDishTagSection] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

-(void)viewDidAppear:(BOOL)animated {
	//Pop out if we aren't logged in
	[super viewDidAppear:animated];
	if ([[AppModel instance].user objectForKey:keyforauthorizing] == nil)
		[[(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:kAccountsTab];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kRestaurantSection:
			return self.restaurantCell.bounds.size.height;
		case kDishNameSection:
			return self.dishNameCell.bounds.size.height;
		case kUploadPictureSection:
			return self.uploadCell.bounds.size.height;
		case kAdditionalDetailsSection:
			return self.additionalDetailsCell.bounds.size.height;
		default:
			break;
	}
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kRestaurantSection:
			return @"Restaurant";
			
		case kDishNameSection:
			return @"Dish Name";
			
		case kDishTagSection:
			return @"Tags";
			
		case kWouldYouRecommendSection:
			return @"Would you recommend this dish?";
			
		case kUploadPictureSection:
			return @"Upload Picture";
			
		case kAdditionalDetailsSection:
			return @"Additional Details";
			
		default:
			break;
	}
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == kDishTagSection) {
		return 2;
	}
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	switch (indexPath.section) {
		case kRestaurantSection:
			cell = self.restaurantCell;
			break;
			
		case kDishNameSection:
			cell = self.dishNameCell;
			break;
			
		case kDishTagSection:
			cell.detailTextLabel.text = @"Make a selection";
			[cell.detailTextLabel setFont:[UIFont italicSystemFontOfSize:12]];
			[cell.detailTextLabel setTextColor:[UIColor redColor]];
			switch (indexPath.row) {
				case kMealTypeRow:
					cell.textLabel.text = @"Meal";
					
					if (self.selectedMealType)
						for (NSDictionary *dict in [[AppModel instance] mealTypeTags])
							if ([[dict objectForKey:@"id"] intValue] == self.selectedMealType) {
								[cell.detailTextLabel setTextColor:[UIColor blackColor]];
								
								cell.detailTextLabel.text = [dict objectForKey:@"name"];
							}
					
					break;
				case kPriceTypeRow:
					cell.textLabel.text = kPriceTypeString;
					if (self.selectedPriceType)
						//TODO, need a lookup for this
						for (NSDictionary *dict in [[AppModel instance] priceTags]) 
							if ([[dict objectForKey:@"id"] intValue] == self.selectedPriceType) {
								[cell.detailTextLabel setTextColor:[UIColor blackColor]];
								cell.detailTextLabel.text = [dict objectForKey:@"name"];
							}
					
				default:
					break;
			}
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			//return because we don't want it transparent
			//this should be like a regular
			return cell;
			
		case kWouldYouRecommendSection:
			cell = self.wouldYouCell;
			break;
			
		case kUploadPictureSection:
			cell = self.uploadCell;
			break;
			
		case kAdditionalDetailsSection:
			cell = self.additionalDetailsCell;
			break;
		default:
			break;
	}
    // Configure the cell...
	UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
	cell.backgroundView = backView;
	[backView release];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	if (indexPath.section == kDishTagSection) {
		self.currentSelection = indexPath.row;
		DishOptionPickerTableViewController *d;
		d = [[DishOptionPickerTableViewController alloc] init];
		[d useThisIntPointer:pointer];
		if(indexPath.row == kMealTypeRow)
			[d setOptionValues:[[AppModel instance] mealTypeTags]];
		else 
			[d setOptionValues:[[AppModel instance] priceTags]];
		
		[self.navigationController pushViewController:d animated:YES];
		[d release];
	}
	
	
}
#pragma mark -
#pragma mark actions

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

-(IBAction)takePicture
{
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Camera or Library?" 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:nil 
													otherButtonTitles:nil];
	[actionSheet addButtonWithTitle:@"Take a picture"];
	[actionSheet addButtonWithTitle:@"Choose from Library"];
	actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
	[actionSheet showInView:self.navigationController.tabBarController.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
        //cancelled
        return;
    }

	NSLog(@"show the picture thing");
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setAllowsEditing:YES];
	
	if(buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
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

-(IBAction)submitDish
{
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addDish"]];
	
	if (!self.rating) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error Submitting Dish" 
															message:@"Please select Yes or No" 
														   delegate:nil 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		return;
	}
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.dishTitle.text forKey:@"name"];
	[request setPostValue:self.additionalDetailsTextView.text forKey:@"description"];
	[request setPostValue:[NSString stringWithFormat:@"%@", [self.restaurant restaurant_id]] forKey:@"restaurantId"];		
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	[request setPostValue:[NSString stringWithFormat:@"%d,%d", self.selectedMealType, self.selectedPriceType] forKey:@"tags"];
		
	NSLog(@"the restaurant id we are sending is %@", 
		  [NSString stringWithFormat:@"%@",
		   [self.restaurant restaurant_id]]);
	NSLog(@"the auth key is %@", [[[AppModel instance] user] objectForKey:keyforauthorizing]);
	NSLog(@"the price type key is %@", [NSNumber numberWithInt:self.selectedPriceType]);
	NSLog(@"the meal type key is %@", [NSNumber numberWithInt:self.selectedMealType]);
	NSLog(@"the name is %@", self.dishTitle.text);
	NSLog(@"the direction is %@", [NSNumber numberWithInt:self.rating]);
	
	mOutstandingRequests = 1;
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	mOutstandingRequests -= 1; 
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"response string for any of these calls %@", responseString);
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	NSLog(@"the dictionary should be a %@", responseAsDict);
	
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
	if ([responseAsDict objectForKey:@"dishId"]) {
		NSURL *url;
		if (self.newPicture.image) {
			NSLog(@"we have the dish id, calling add photo");
			self.dishId = [[responseAsDict objectForKey:@"dishId"] intValue];
			url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
			NSLog(@"the url for add photo is %@", url);
			newRequest = [ASIFormDataRequest requestWithURL:url];
			[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
			[newRequest setPostValue:[NSString stringWithFormat:@"%d", self.dishId] forKey:@"dishId"];
			[newRequest setDelegate:self];
			[newRequest startAsynchronous];
			mOutstandingRequests += 1;
			NSLog(@"done calling add photo, time to call rateDish");
		}
		
		url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/rateDish"]];
		NSLog(@"the url for rate dish is %@", url);

		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", self.dishId] forKey:@"dishId"];
		[newRequest setPostValue:[NSNumber numberWithInt:self.rating] forKey:@"direction"];
		[newRequest setPostValue:self.commentTextView.text forKey:@"comment"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		mOutstandingRequests += 1;
		NSLog(@"done calling rate Dish");
		return;
	}
	if ([responseAsDict objectForKey:@"url"]) {
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [responseAsDict objectForKey:@"url"]]];
		NSLog(@"the url for sending the photo is %@", url);

		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setData:UIImagePNGRepresentation(self.newPicture.image) forKey:@"photo"];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", self.dishId] forKey:@"dishId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		mOutstandingRequests += 1;
		return;

	}
	if (!mOutstandingRequests)
		[self.navigationController popViewControllerAnimated:YES];	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	mOutstandingRequests -= 1;
	if (!mOutstandingRequests)
		[self.navigationController popViewControllerAnimated:YES];	
	NSError *error = [request error];
	NSLog(@"error %@", error);
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
	self.restaurant = nil;
	self.restaurantCell = nil;
	self.restaurantTitle = nil;
	self.dishNameCell = nil;
	self.dishTitle = nil;
	self.wouldYouCell = nil;
	self.yesImage = nil;
	self.noImage = nil;
	self.uploadCell = nil;
	self.newPicture = nil;
	self.additionalDetailsCell = nil;
	self.additionalDetailsTextView = nil;
	self.commentTextView = nil;
	self.submitButton = nil;
	
    [super dealloc];
	free(pointer);
}


@end

