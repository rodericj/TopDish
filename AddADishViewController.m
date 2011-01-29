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

#define kRestaurantSection 0
#define kDishNameSection 1
#define kDishTagSection 2
#define kWouldYouRecommendSection 3
#define kUploadPictureSection 4
#define kAdditionalDetailsSection 5

#define kMealTypeRow 0
#define kPriceTypeRow 1

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
@synthesize submitButton = mSubmitButton;

@synthesize selectedMealType = mSelectedMealType;
@synthesize selectedPriceType = mSelectedPriceType;
@synthesize currentSelection = mCurrentSelection;

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
		self.selectedMealType = *pointer;
	else
		self.selectedPriceType = *pointer;

    [super viewWillAppear:animated];
	[self.tableView beginUpdates];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kDishTagSection] withRowAnimation:UITableViewRowAnimationFade];
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
			switch (indexPath.row) {
				case kMealTypeRow:
					cell.textLabel.text = @"Meal";
					cell.detailTextLabel.text = [[[AppModel instance] mealTypeTags] objectAtIndex:self.selectedMealType];
					break;
				case kPriceTypeRow:
					cell.textLabel.text = @"Price";
					cell.detailTextLabel.text = [[[AppModel instance] priceTags] objectAtIndex:self.selectedPriceType];
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
	UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	//backView.backgroundColor = [UIColor clearColor];
	cell.backgroundView = backView;

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

-(IBAction)submitDish
{
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addDish"]];
	
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
	[request setPostValue:self.dishTitle.text forKey:@"name"];
	[request setPostValue:self.additionalDetailsTextView.text forKey:@"description"];
	[request setPostValue:[NSString stringWithFormat:@"%@", [self.restaurant restaurant_id]] forKey:@"restaurantId"];		
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	[request setPostValue:[NSNumber numberWithInt:self.selectedPriceType] forKey:@"price"];
	[request setPostValue:[NSNumber numberWithInt:self.selectedMealType]	forKey:@"mealType"];

	//NSLog(@"posting to AddADish dish: %@\nadditional: %@\n restaurant_id\n%@auth_key: %@\nprice: %dmeal type: %d", 
//		  self.dishTitle.text, self.additionalDetailsTextView.text, 
//		  [[[AppModel instance] user] objectForKey:keyforauthorizing], 
//		  self.selectedPriceType, self.selectedMealType);
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
    [super dealloc];
	free(pointer);
}


@end

