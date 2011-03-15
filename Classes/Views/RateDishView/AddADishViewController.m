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
#import "AppModel.h"
#import "TopDishAppDelegate.h"
#import "JSON.h"

#define kRestaurantSection 0
#define kDishNameSection 1
#define kDishTagSection 2
#define kWouldYouRecommendSection 3
#define kUploadPictureSection 4
#define kAdditionalDetailsSection 5

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

@synthesize pickerArray = mPickerArray;
@synthesize pickerView = mPickerView;
@synthesize pickerViewOverlay = mPickerViewOverlay;
@synthesize pickerViewButton = mPickerViewButton;
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
	self.restaurantTitle.text = [self.restaurant objName];
}



- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
	[self.tableView beginUpdates];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDishTagSection] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

-(void)viewDidAppear:(BOOL)animated {
	//Pop out if we aren't logged in
	[super viewDidAppear:animated];
	//if ([[AppModel instance].user objectForKey:keyforauthorizing] == nil)
//		[[(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:kAccountsTab];
}

#pragma mark -
#pragma mark PickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	DLog(@"they picked %d", row);
	pickerSelected = row;
	
	}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[self.pickerArray objectAtIndex:row] objectForKey:@"name"];
}


#pragma mark -
#pragma mark Picker view delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.pickerArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

-(IBAction) pickerDone {
	
	[self.tableView setScrollEnabled:YES];
	[self.tableView addSubview:self.pickerViewOverlay];
	[UIView beginAnimations:@"animatePickerOn" context:NULL]; // Begin animation
	mPickerUp = NO;
	[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, self.pickerViewOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[self.pickerViewOverlay setHidden:YES];
	[self.tableView setUserInteractionEnabled:YES];
	
	NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
	
	AppModel *app = [AppModel instance];
	switch (selectedPath.row) {
		case kMealType:
			DLog(@"we selected %@", [[app mealTypeTags] objectAtIndex:pickerSelected]);
			[app setMealTypeByIndex:pickerSelected];
			
			break;
		case kPriceType:
			DLog(@"we selected %@", [[app priceTags] objectAtIndex:pickerSelected]);
			[app setPriceTypeByIndex:pickerSelected];
			
			break;
		case kAllergenType:
			DLog(@"we selected %@", [[app allergenTags] objectAtIndex:pickerSelected]);
			[app setAllergenTypeByIndex:pickerSelected];
			break;
		case kCuisineType:
			DLog(@"we selected %@", [[app cuisineTypeTags] objectAtIndex:pickerSelected]);
			[app setCuisineTypeByIndex:pickerSelected];
			break;
		case kLifestyleType:
			DLog(@"we selected %@", [[app lifestyleTags] objectAtIndex:pickerSelected]);
			[app setLifestyleTypeByIndex:pickerSelected];
			break;
		default:
			break;
	}
	
	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedPath] 
						  withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
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
    
	AppModel *app = [AppModel instance];
	
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
				case kMealType:
					cell.textLabel.text = @"Meal";
					if ([[app selectedMeal] intValue] != 0) {
						cell.detailTextLabel.text = [app selectedMealName];
						cell.detailTextLabel.textColor = [UIColor blackColor];
					}
					else {
						cell.detailTextLabel.text = @"Make a Selection";
						cell.detailTextLabel.textColor = [UIColor redColor];
						
					}					
					break;
				case kPriceType:
					
					cell.textLabel.text = kPriceTypeString;
					if ([[app selectedPrice] intValue] != 0) {
						cell.detailTextLabel.text = [app selectedPriceName];
						cell.detailTextLabel.textColor = [UIColor blackColor];
					}
					else {
						cell.detailTextLabel.text = @"Make a Selection";
						cell.detailTextLabel.textColor = [UIColor redColor];

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
		NSAssert(NO, @"need to implement selection again");
		self.currentSelection = indexPath.row;
		
		switch (indexPath.row) {
			case kMealType:
				self.pickerArray = [[AppModel instance] mealTypeTags];
				break;
				
			case kLifestyleType:
				self.pickerArray = [[AppModel instance] lifestyleTags];
				break;
				
			case kCuisineType:
				self.pickerArray = [[AppModel instance] cuisineTypeTags] ;
				break;			
				
			case kAllergenType:
				self.pickerArray = [[AppModel instance] allergenTags];
				break;
				
			case kPriceType:
				self.pickerArray = [[AppModel instance] priceTags];
				break;
				
			default:
				break;
		}
		
		self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.pickerView reloadAllComponents];
		
		// add this picker to our view controller, initially hidden
		NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
		
		//handle special needs for the tableView
		[self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
		[self.tableView setScrollEnabled:NO];
		[self.tableView addSubview:self.pickerViewOverlay];
		//[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, self.pickerViewOverlay.frame.size.height)]; // Move imageView off screen

		//animate
		if (!mPickerUp) {
			NSLog(@"the frame of the picker is %@", [self.pickerViewOverlay frame]);
			[UIView beginAnimations:@"animatePickerOn" context:NULL]; // Begin animation
			[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, -self.pickerViewOverlay.frame.size.height)]; // Move imageView off screen
			mPickerUp = TRUE;
			[UIView commitAnimations]; // End animations
			[self.pickerViewOverlay setHidden:NO];
		}
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
	[actionSheet release];
}

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
		
	DLog(@"the restaurant id we are sending is %@", 
		  [NSString stringWithFormat:@"%@",
		   [self.restaurant restaurant_id]]);
	DLog(@"the auth key is %@", [[[AppModel instance] user] objectForKey:keyforauthorizing]);
	DLog(@"the price type key is %@", [NSNumber numberWithInt:self.selectedPriceType]);
	DLog(@"the meal type key is %@", [NSNumber numberWithInt:self.selectedMealType]);
	DLog(@"the name is %@", self.dishTitle.text);
	DLog(@"the direction is %@", [NSNumber numberWithInt:self.rating]);
	
	mOutstandingRequests = 1;
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	mOutstandingRequests -= 1; 
	// Use when fetching text data
	NSString *responseString = [request responseString];
	DLog(@"response string for any of these calls %@", responseString);
	
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
	if ([responseAsDict objectForKey:@"dishId"]) {
		NSURL *url;
		if (self.newPicture.image) {
			DLog(@"we have the dish id, calling add photo");
			self.dishId = [[responseAsDict objectForKey:@"dishId"] intValue];
			url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
			DLog(@"the url for add photo is %@", url);
			newRequest = [ASIFormDataRequest requestWithURL:url];
			[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
			[newRequest setPostValue:[NSString stringWithFormat:@"%d", self.dishId] forKey:@"dishId"];
			[newRequest setDelegate:self];
			[newRequest startAsynchronous];
			mOutstandingRequests += 1;
			DLog(@"done calling add photo, time to call rateDish");
		}
		
		url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/rateDish"]];
		DLog(@"the url for rate dish is %@", url);

		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", self.dishId] forKey:@"dishId"];
		[newRequest setPostValue:[NSNumber numberWithInt:self.rating] forKey:@"direction"];
		[newRequest setPostValue:self.commentTextView.text forKey:@"comment"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		mOutstandingRequests += 1;
		DLog(@"done calling rate Dish");
		return;
	}
	if ([responseAsDict objectForKey:@"url"]) {
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [responseAsDict objectForKey:@"url"]]];
		DLog(@"the url for sending the photo is %@", url);

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
	DLog(@"error %@", [request error]);
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
	DLog(@"cancelled, should we go back another level?");
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
}


@end

