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

#define kMealTypeSection 2
#define kPriceFilterSection 1
#define kSortingSection 0

@implementation SettingsView1

@synthesize segmentedControl = mSegmentedControl;
@synthesize segmentedControlCell = mSegmentedControlCell;
@synthesize priceSliderCell = mPriceSliderCell;
@synthesize priceValueCell = mPriceValueCell;
@synthesize priceValue = mPriceValue;
@synthesize priceSlider = mPriceSlider;
@synthesize mealTypeCell = mMealTypeCell;
@synthesize mealTypeLabel = mMealTypeLabel;

- (void)viewDidLoad {
	NSLog(@"count is %d",[[[AppModel instance] priceTags] count] );
	[self.priceSlider setMaximumValue:[[[AppModel instance] priceTags] count] - 1];
	[self.priceSlider setMinimumValue:0];
	[self.priceSlider setValue:0];
}

- (void)viewWillAppear:(BOOL)animated {
	AppModel *a = [AppModel instance];
	NSLog(@"meal type tags %@, %d", [a mealTypeTags], [a selectedMealType]);
	[self.mealTypeLabel setText:[[a mealTypeTags] objectAtIndex:[a selectedMealType]]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kMealTypeSection:
			return 1;
		case kPriceFilterSection:
			return 2;
			break;
		case kSortingSection:
			return 1;
		default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kMealTypeSection:
			return @"Meal Type";
			break;
		case kPriceFilterSection:
			return @"Price";
			break;
		case kSortingSection:
			return @"Sort by";
		default:
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell = self.segmentedControlCell;
	}
	if (indexPath.section == kPriceFilterSection && indexPath.row == 0) {
		cell = self.priceSliderCell;
	}
	if (indexPath.section == kPriceFilterSection && indexPath.row == 1) {
		cell = self.priceValueCell;
	}
	if (indexPath.section == kMealTypeSection) {
		cell = self.mealTypeCell;
	}
    // Configure the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(IBAction) changeSegmentedSelector {
	NSLog(@"blah %d", [self.segmentedControl selectedSegmentIndex]);
	[[AppModel instance] setSorter:[self.segmentedControl selectedSegmentIndex]];
}

-(IBAction) updatePriceTags{
	[self.priceSlider setValue:(int)[self.priceSlider value]];
	[self.priceValue setText:[[AppModel instance].priceTags objectAtIndex:[self.priceSlider value]]];	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kMealTypeSection) {
		
		DishOptionPickerTableViewController *d = [[DishOptionPickerTableViewController alloc] init];
		[d setOptionValues:[[AppModel instance] mealTypeTags]];
		[d setOptionType:kMealType];
		[self.navigationController pushViewController:d animated:YES];
		[d release];
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
    [super dealloc];
	self.segmentedControl = nil;
	self.segmentedControlCell = nil;
	self.priceSliderCell = nil;
	self.priceSlider = nil;
	self.priceValueCell = nil;
	self.priceValue = nil;
	self.mealTypeCell = nil;
	self.mealTypeLabel = nil;
}


@end

