//
//  SettingsView1.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsView1.h"
#import "AppModel.h"
#import "DishOptionPickerTableViewController.h"
#import "constants.h"

#define kNumberOfDifferentTypes 4

@implementation SettingsView1

@synthesize priceSliderCell = mPriceSliderCell;
@synthesize priceValueCell = mPriceValueCell;
@synthesize priceValue = mPriceValue;
@synthesize priceSlider = mPriceSlider;
@synthesize mealTypeCell = mMealTypeCell;

@synthesize pickerArray = mPickerArray;
@synthesize pickerView = mPickerView;
@synthesize pickerViewOverlay = mPickerViewOverlay;
@synthesize pickerViewButton = mPickerViewButton;

- (void)viewDidLoad {
	self.view.backgroundColor = kTopDishBackground;
	[self.priceSlider setMaximumValue:[[[AppModel instance] priceTags] count] - 1];
	[self.priceSlider setMinimumValue:0];
	[self.priceSlider setValue:0];
	NSLog(@"loading and the selectedmeal type is %d", [[AppModel instance] selectedMeal]);
	int count = 0;

	for (NSDictionary *d in [[AppModel instance] mealTypeTags]) {
		if ([d objectForKey:@"id"] == [[AppModel instance] selectedMeal]) {
			continue;
		}
		count++;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kNumberOfDifferentTypes;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
    }
    
	if (indexPath.section == kPriceType && indexPath.row == 0) {
		cell = self.priceSliderCell;
	}
	if (indexPath.section == kPriceType && indexPath.row == 1) {
		cell = self.priceValueCell;
	}
	if (indexPath.section == kMealType) {	
		
		cell.textLabel.text = kMealTypeString;
		cell.detailTextLabel.text = [a selectedMealName];
	}
	
	if (indexPath.section == kCuisineType) {		
		cell.textLabel.text = kCuisineTypeString;
		cell.detailTextLabel.text = [a selectedCuisineName];
	}
	
	if (indexPath.section == kLifestyleType) {
		cell.textLabel.text = kLifestyleTypeString;
		cell.detailTextLabel.text = [a selectedLifestyleName];
	}
	
	if (indexPath.section == kAllergenType) {
		cell.textLabel.text = kAllergenTypeString;
		cell.detailTextLabel.text = [a selectedAllergenName];
	}
    // Configure the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma mark -
#pragma mark IBActions
-(IBAction) pickerDone {
	
	[self.tableView setScrollEnabled:YES];
	[self.tableView addSubview:self.pickerViewOverlay];
	[UIView beginAnimations:@"animatePickerOn" context:NULL]; // Begin animation
	[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, self.pickerViewOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[self.pickerViewOverlay setHidden:YES];
	
	NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
	
	AppModel *app = [AppModel instance];
	switch (selectedPath.section) {
		case kMealType:
			NSLog(@"we selected %@", [[app mealTypeTags] objectAtIndex:pickerSelected]);
			[app setMealTypeByIndex:pickerSelected];
			
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
						  withRowAnimation:UITableViewRowAnimationLeft];
	[self.tableView endUpdates];
}

-(IBAction) updatePriceTags{
	
	[self.priceSlider setValue:(int)[self.priceSlider value]];
	NSDictionary *d = [[AppModel instance].priceTags objectAtIndex:[self.priceSlider value]];
	[self.priceValue setText:[d objectForKey:@"name"]];
	int priceTagId = [[[[[AppModel instance] priceTags] objectAtIndex: [self.priceSlider value]] objectForKey:@"id"] intValue];
	[[AppModel instance] setSelectedPrice:priceTagId];
	
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
	
	
	switch (indexPath.section) {
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
	[UIView beginAnimations:@"animatePickerOn" context:NULL]; // Begin animation
	[self.pickerViewOverlay setFrame:CGRectOffset([self.pickerViewOverlay frame], 0, -self.pickerViewOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[self.pickerViewOverlay setHidden:NO];
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
	self.priceSliderCell = nil;
	self.priceSlider = nil;
	self.priceValueCell = nil;
	self.priceValue = nil;
	self.mealTypeCell = nil;
	[super dealloc];
}


@end

