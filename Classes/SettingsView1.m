//
//  SettingsView1.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsView1.h"
#import "AppModel.h"
#import "constants.h"

#define kNumberOfDifferentTypes 4

@implementation SettingsView1

@synthesize pickerArray = mPickerArray;
@synthesize pickerView = mPickerView;
@synthesize pickerViewOverlay = mPickerViewOverlay;
@synthesize pickerViewButton = mPickerViewButton;

- (void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;

	//NSLog(@"loading and the selectedmeal type is %d", [[AppModel instance] selectedMeal]);
	//int count = 0;

	//for (NSDictionary *d in [[AppModel instance] mealTypeTags]) {
//		if ([d objectForKey:@"id"] == [[AppModel instance] selectedMeal]) {
//			continue;
//		}
//		count++;
//	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return kNumberOfDifferentTypes;
	switch (section) {
		case kAllergenType:
		case kLifestyleType:
		case kCuisineType:
		case kMealType:
			return 1;
		case kPriceType:
			return 2;
			break;
		default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Filters";
	switch (section) {
		case kAllergenType:
			return kAllergenTypeString;
		case kLifestyleType:
			return kLifestyleTypeString;
		case kCuisineType:
			return kCuisineTypeString;
		case kMealType:
			return kMealTypeString;
		case kPriceType:
			return kPriceTypeString;

		default:
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    AppModel *a = [AppModel instance];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		[cell.textLabel setTextColor:kTopDishBlue];
    }
    
	if (indexPath.row == kPriceType) {	
		
		cell.textLabel.text = kPriceTypeString;
		cell.detailTextLabel.text = [a selectedPriceName];
	}
	if (indexPath.row == kMealType) {	
		
		cell.textLabel.text = kMealTypeString;
		cell.detailTextLabel.text = [a selectedMealName];
	}
	
	if (indexPath.row == kCuisineType) {		
		cell.textLabel.text = kCuisineTypeString;
		cell.detailTextLabel.text = [a selectedCuisineName];
	}
	
	if (indexPath.row == kLifestyleType) {
		cell.textLabel.text = kLifestyleTypeString;
		cell.detailTextLabel.text = [a selectedLifestyleName];
	}
	
	if (indexPath.row == kAllergenType) {
		cell.textLabel.text = kAllergenTypeString;
		cell.detailTextLabel.text = [a selectedAllergenName];
	}
    // Configure the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	//[cell setBackgroundColor:[UIColor redColor]];
    return cell;
}
#pragma mark -
#pragma mark IBActions
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
			NSLog(@"we selected %@", [[app mealTypeTags] objectAtIndex:pickerSelected]);
			[app setMealTypeByIndex:pickerSelected];
			
			break;
		case kPriceType:
			NSLog(@"we selected %@", [[app priceTags] objectAtIndex:pickerSelected]);
			[app setPriceTypeByIndex:pickerSelected];
			
			break;
		case kAllergenType:
			NSLog(@"we selected %@", [[app allergenTags] objectAtIndex:pickerSelected]);
			[app setAllergenTypeByIndex:pickerSelected];
			break;
		case kCuisineType:
			NSLog(@"we selected %@", [[app cuisineTypeTags] objectAtIndex:pickerSelected]);
			[app setCuisineTypeByIndex:pickerSelected];
			break;
		case kLifestyleType:
			NSLog(@"we selected %@", [[app lifestyleTags] objectAtIndex:pickerSelected]);
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
#pragma mark PickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSLog(@"they picked %d", row);
	pickerSelected = row;
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[self.pickerArray objectAtIndex:row] objectForKey:@"name"];
}


#pragma mark -
#pragma mark Table view delegate
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
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
	
	//animate
	if (!mPickerUp) {
		
		[UIView beginAnimations:@"animatePickerOn" context:NULL]; // Begin animation
		[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, -self.pickerViewOverlay.frame.size.height-14)]; // Move imageView off screen
		mPickerUp = TRUE;
		[UIView commitAnimations]; // End animations
		[self.pickerViewOverlay setHidden:NO];
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
	self.pickerArray = nil;
	self.pickerView = nil;
	self.pickerViewOverlay = nil;
	self.pickerViewButton = nil;
	[super dealloc];
}


@end

