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
#import "Dish.h"
#import "FeedbackStringProcessor.h"

#define kRestaurantSection 0
#define kDishNameSection 1
#define kDishTagSection 2
#define kDishDescriptionSection 3

#define kNumberOfSections 4

#define kTextViewRect CGRectMake(11, 5, 280, 70)

#define kAdditionalDetailsDefaultText @"Include as many ingredients as possible, descriptions from menus are ok. Eg. Cheese-filled thin pancakes, served with house-made apple sauce and sour cream"
#define kPleaseCommentDefaultText @"The more descriptive your review the more helpful it will be to future users and restaurants"

#define kAddDishViewTextColor [UIColor colorWithRed:.3019 green:.2588 blue:.1686 alpha:1]

@implementation AddADishViewController

@synthesize restaurant = mRestaurant;
@synthesize managedObjectContext=managedObjectContext_;

@synthesize restaurantCell = mRestaurantCell;
@synthesize restaurantTitle = mRestaurantTitle;

@synthesize dishNameCell = mDishNameCell;
@synthesize dishTitle = mDishTitle;

@synthesize submitButton = mSubmitButton;

@synthesize selectedMealType = mSelectedMealType;
@synthesize selectedPriceType = mSelectedPriceType;

@synthesize dishId = mDishId;

@synthesize pickerArray = mPickerArray;
@synthesize pickerView = mPickerView;
@synthesize pickerViewOverlay = mPickerViewOverlay;
@synthesize pickerViewButton = mPickerViewButton;
@synthesize delegate = mDelegate;

@synthesize additionalDetailsCell = mAdditionalDetailsCell;
@synthesize additionalDetailsTextView = mAdditionalDetailsTextView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = kTopDishBackground;
	self.restaurantTitle.text = [self.restaurant objName];
	self.tableView.tableFooterView = self.additionalDetailsCell;
	
	self.additionalDetailsTextView = [[[UITextView alloc] initWithFrame:kTextViewRect] autorelease];
	self.additionalDetailsTextView.delegate = self;
	self.additionalDetailsTextView.text = kAdditionalDetailsDefaultText;

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
	if (![[AppModel instance] isLoggedIn])
		[self.navigationController popViewControllerAnimated:YES];
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
			self.selectedMealType = [[[[app mealTypeTags] objectAtIndex:pickerSelected] objectForKey:@"id"] intValue];
			
			break;
		case kPriceType:
			DLog(@"we selected %@", [[app priceTags] objectAtIndex:pickerSelected]);
			self.selectedPriceType = [[[[app priceTags] objectAtIndex:pickerSelected] objectForKey:@"id"] intValue];			
			break;
			
		//case kAllergenType:
//			DLog(@"we selected %@", [[app allergenTags] objectAtIndex:pickerSelected]);
//			self.selectedA
//			break;
//		case kCuisineType:
//			DLog(@"we selected %@", [[app cuisineTypeTags] objectAtIndex:pickerSelected]);
//			[app setCuisineTypeByIndex:pickerSelected];
//			break;
//		case kLifestyleType:
//			DLog(@"we selected %@", [[app lifestyleTags] objectAtIndex:pickerSelected]);
//			[app setLifestyleTypeByIndex:pickerSelected];
//			break;
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

- (void)textViewDidBeginEditing:(UITextView *)textView{
	if (textView.tag == 0) {
		textView.text = @"";
		textView.tag = 1;
	}
	
}


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
		case kDishDescriptionSection:
			return 80;
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
		case kDishDescriptionSection:
			return @"What's in the dish?";
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
	if (section == kDishTagSection) {
		return 2;
	}

    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.additionalDetailsTextView resignFirstResponder];
	[self.dishTitle resignFirstResponder];
	
    static NSString *CellIdentifier = @"Cell";
    
	AppModel *app = [AppModel instance];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSArray *subViews = cell.subviews;
	for (UIView *v in subViews)
		if ([v class] == [UITextView class])
			[v removeFromSuperview];
	
	// Configure the cell...
	UIView *backView;
	switch (indexPath.section) {
		case kRestaurantSection:
			cell = self.restaurantCell;
			backView = [[UIView alloc] initWithFrame:CGRectZero];
			cell.backgroundView = backView;
			[backView release];
			break;
			
		case kDishNameSection:
			cell = self.dishNameCell;
			backView = [[UIView alloc] initWithFrame:CGRectZero];
			cell.backgroundView = backView;
			[backView release];
			break;
			
		case kDishTagSection:
			cell.detailTextLabel.text = @"Make a selection";
			[cell.detailTextLabel setFont:[UIFont italicSystemFontOfSize:12]];
			[cell.detailTextLabel setTextColor:[UIColor redColor]];
			switch (indexPath.row) {
				case kMealType:
					cell.textLabel.text = @"Meal";
					if(self.selectedMealType != 0) {
						for(NSDictionary *d in [app mealTypeTags]){
							if ([[d objectForKey:@"id"] intValue] == self.selectedMealType) {
								cell.detailTextLabel.text = [d objectForKey:@"name"];
							}
						}
							
						cell.detailTextLabel.textColor = [UIColor blackColor];
					}
					else {
						cell.detailTextLabel.text = @"Make a Selection";
						cell.detailTextLabel.textColor = [UIColor redColor];
						
					}					
					break;
				case kPriceType:
					
					cell.textLabel.text = kPriceTypeString;
					
					if(self.selectedPriceType != 0) {
						for(NSDictionary *d in [app priceTags]){
							if ([[d objectForKey:@"id"] intValue] == self.selectedPriceType) {
								cell.detailTextLabel.text = [d objectForKey:@"name"];
							}
						}
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
			
		case kDishDescriptionSection:
			cell.accessoryType = UITableViewCellAccessoryNone;
			[cell addSubview:self.additionalDetailsTextView];
			break;
        default:
			break;
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	if (indexPath.section == kDishTagSection) {
		//NSAssert(NO, @"need to implement selection again");
		
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
			DLog(@"the frame of the picker is %@", [self.pickerViewOverlay frame]);
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

-(IBAction)submitDish
{
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addDish"]];
	
	
	if ([self.dishTitle.text length] == 0 || !self.dishTitle.text) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error Submitting Dish" 
															message:@"Invalid Dish Title" 
														   delegate:nil 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		return;
	}
	
	if ([self.additionalDetailsTextView.text length] == 0 || 
		!self.additionalDetailsTextView.text || 
		([self.additionalDetailsTextView.text isEqualToString:kAdditionalDetailsDefaultText])) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error Submitting Dish" 
															message:@"Invalid Description: This should be what you'd see on the menu" 
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
	DLog(@"request to add dish %@", request);
	DLog(@"request url is %@", url);
	mOutstandingRequests = 1;
	[request setDelegate:self];
	[request startAsynchronous];
	
	mHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	mHUD.mode = MBProgressHUDModeDeterminate;
	mHUD.progress = 0.1;
	mHUD.labelText = @"Adding dish";
	mHUD.delegate = self;
	self.tableView.userInteractionEnabled = NO;
}

#pragma mark -
#pragma mark network request
- (void)requestFinished:(ASIHTTPRequest *)request
{
	mHUD.progress +=  .333;
	mOutstandingRequests -= 1; 
	// Use when fetching text data
	NSString *responseString = [request responseString];
	DLog(@"response string for any of these calls %@", responseString);
	
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
	
	DLog(@"the dictionary is %@", responseAsDict);
		
	if ([[responseAsDict objectForKey:@"rc"] intValue]) {
		mHUD.labelText = @"Error while Uploading";
		[mHUD hide:YES afterDelay:2];		
		return;
	}

    //We did not have an error. Create and save the dish
    
    
    
    //Need to add just one dish
    Dish *newlyCreatedDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
                                                                   inManagedObjectContext:kManagedObjectContext];
    
    [newlyCreatedDish setDish_id:[responseAsDict objectForKey:@"dishId"]];
    
    [newlyCreatedDish setObjName:self.dishTitle.text];
    [newlyCreatedDish setDish_description:self.additionalDetailsTextView.text];
    [newlyCreatedDish setLatitude:self.restaurant.latitude];
    [newlyCreatedDish setLongitude:self.restaurant.longitude];
        
    //Add this dish to the restaurant
    [newlyCreatedDish setRestaurant:self.restaurant];
    
    [newlyCreatedDish setMealType:[NSNumber numberWithInt:self.selectedMealType]];
    [newlyCreatedDish setPrice:[NSNumber numberWithInt:self.selectedPriceType]];
    
    if(![kManagedObjectContext save:&error]){
        DLog(@"there was a core data error when saving a single dish");
        DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
    }
		
	if (!mOutstandingRequests) {
		mUploadSuccess = YES;
		mHUD.progress = 1;
		mHUD.labelText = @"Upload complete";
		[mHUD hide:YES];
        RateADishViewController *rateDish = [[RateADishViewController alloc] initWithNibName:@"RateADishViewController" 
                                                                                      bundle:nil];
        [rateDish setThisDish:newlyCreatedDish];
        [rateDish setDelegate:self];
        [self.navigationController pushViewController:rateDish 
                                             animated:YES];
        
        [rateDish release];	
	}
}

-(void)doneRatingDish {
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate addDishDone];
}

-(void)hudWasHidden {
	self.tableView.userInteractionEnabled = YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	mOutstandingRequests -= 1;
	mHUD.progress = 0;
	mHUD.labelText = @"Adding the dish Failed";
	[mHUD hide:YES afterDelay:2];
	DLog(@"error %@", [request error]);
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

	self.additionalDetailsCell = nil;
	self.additionalDetailsTextView = nil;
	self.submitButton = nil;
	
    [super dealloc];
}


@end

