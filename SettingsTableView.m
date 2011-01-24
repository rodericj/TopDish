//
//  SettingsTableView.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableView.h"

#define kfilters 1
#define kSorting 0

@implementation SettingsTableView

@synthesize segmentedControl = mSegmentedControl;

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kfilters:
			return 2;
			break;
		case kSorting:
			return 1;
		default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kfilters:
			return @"Filters";
			break;
		case kSorting:
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
    }
    // Configure the cell...
    if (indexPath.row == 0 && indexPath.section == 0) {
		self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Ratings", @"Distance", nil]];
		self.segmentedControl.frame = CGRectMake(10, 0, 300, 50);
		[cell addSubview:self.segmentedControl];
	}
	
	if (indexPath.row == 0 && indexPath.section == 1) {
		cell.textLabel.text = @"hi";
		cell.detailTextLabel.text = @"cool";
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	
	if (indexPath.row == 1 && indexPath.section == 1) {
		cell.textLabel.text = @"hi";
		cell.detailTextLabel.text = @"cool";
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
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



- (void)dealloc {
    [super dealloc];
	self.segmentedControl = nil;
}


@end

