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

#define kAllergenTypeSection 4
#define kLifestyleTypeSection 3
#define kCuisineTypeSection 2
#define kMealTypeSection 1
#define kPriceFilterSection 0

@implementation SettingsView1

@synthesize priceSliderCell = mPriceSliderCell;
@synthesize priceValueCell = mPriceValueCell;
@synthesize priceValue = mPriceValue;
@synthesize priceSlider = mPriceSlider;
@synthesize mealTypeCell = mMealTypeCell;

- (void)viewDidLoad {
	pointer = malloc(sizeof(int));
	self.view.backgroundColor = kTopDishBackground;
	[self.priceSlider setMaximumValue:[[[AppModel instance] priceTags] count] - 1];
	[self.priceSlider setMinimumValue:0];
	[self.priceSlider setValue:0];
	NSLog(@"loading and the selectedmeal type is %d", [[AppModel instance] selectedMealType]);
	int count = 0;

	for (NSDictionary *d in [[AppModel instance] mealTypeTags]) {
		if ([[d objectForKey:@"id"] intValue] == [[AppModel instance] selectedMealType]) {
			*pointer = count;
			continue;
		}
		count++;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:kMealTypeSection];

	NSLog(@"the price at pointer is %@", [[[AppModel instance] mealTypeTags] objectAtIndex:*pointer]);
	int mealtype = [[[[[AppModel instance] mealTypeTags] objectAtIndex:*pointer] objectForKey:@"id"] intValue];
	NSLog(@"the mealType id is %d", mealtype);
	[[AppModel instance] setSelectedMealType:mealtype];
	
	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
	
	int selectedPrice = [[AppModel instance] selectedPrice];
	int count = 0;
	for (NSDictionary *d in [[AppModel instance] priceTags]) {
		if ([[d objectForKey:@"id"] intValue] == selectedPrice) {
			NSLog(@"the selected price is %@", [d objectForKey:@"name"]);
			[self.priceValue setText:[d objectForKey:@"name"]];
			[self.priceSlider setValue:count];
			continue;
		}
		count++;
	}
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kNumberOfDifferentTypes + 1; //+ 1 for the prices
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kAllergenTypeSection:
		case kLifestyleTypeSection:
		case kCuisineTypeSection:
		case kMealTypeSection:
			return 1;
		case kPriceFilterSection:
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
		case kAllergenTypeSection:
			return kAllergenTypeString;
		case kLifestyleTypeSection:
			return kLifestyleTypeString;
		case kCuisineTypeSection:
			return kCuisineTypeString;
		case kMealTypeSection:
			return kMealTypeString;
		case kPriceFilterSection:
			return kPriceTypeString;

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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section == kPriceFilterSection && indexPath.row == 0) {
		cell = self.priceSliderCell;
	}
	if (indexPath.section == kPriceFilterSection && indexPath.row == 1) {
		cell = self.priceValueCell;
	}
	if (indexPath.section == kMealTypeSection && indexPath.row == 0) {
		//cell = self.mealTypeCell;
		AppModel *a = [AppModel instance];

		cell.textLabel.text = kMealTypeString;
		
		if (*pointer > 0 && *pointer < [[a mealTypeTags] count]) {
			NSLog(@"now set the meal type to %@", [[a mealTypeTags] objectAtIndex:*pointer]);
			cell.detailTextLabel.text = [[[a mealTypeTags] objectAtIndex:*pointer] objectForKey:@"name"];
		}
		
		for (NSDictionary *d in [a mealTypeTags]) {
			if ([[d objectForKey:@"id"] intValue] == [a selectedMealType]) {
				cell.detailTextLabel.text = [d objectForKey:@"name"];
				continue;
			}
		}
		
		
		
		//cell.detailTextLabel.text = [[AppModel instance] pr
	}
	
	if (indexPath.section == kCuisineTypeSection) {		
		cell.textLabel.text = kCuisineTypeString;
		
		//TODO: something will happen when click.
	}
	
	if (indexPath.section == kLifestyleTypeSection) {
		cell.textLabel.text = kLifestyleTypeString;
		
		//TODO: something will happen when click.
	}
	
	if (indexPath.section == kAllergenTypeSection) {
		cell.textLabel.text = kAllergenTypeString;
		
		//TODO: something will happen when click.
	}
    // Configure the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma mark -
#pragma mark IBActions

-(IBAction) updatePriceTags{
	[self.priceSlider setValue:(int)[self.priceSlider value]];
	NSDictionary *d = [[AppModel instance].priceTags objectAtIndex:[self.priceSlider value]];
	[self.priceValue setText:[d objectForKey:@"name"]];
	int priceTagId = [[[[[AppModel instance] priceTags] objectAtIndex: [self.priceSlider value]] objectForKey:@"id"] intValue];

	[[AppModel instance] setSelectedPrice:priceTagId];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		DishOptionPickerTableViewController *d = [[DishOptionPickerTableViewController alloc] init];
	
	switch (indexPath.section) {
		case kMealTypeSection:
			[d setOptionValues:[[AppModel instance] mealTypeTags]];
			[d setOptionType:kMealType];
			break;
			
		case kLifestyleTypeSection:
			[d setOptionValues:[[AppModel instance] lifestyleTags]];
			[d setOptionType:kLifestyleType];
			break;
			
		case kCuisineTypeSection:
			[d setOptionValues:[[AppModel instance] cuisineTypeTags]];
			[d setOptionType:kCuisineType];
			break;
			
		default:
			break;
	}
	[d useThisIntPointer:pointer];
	[self.navigationController pushViewController:d animated:YES];
	[d release];
	
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

