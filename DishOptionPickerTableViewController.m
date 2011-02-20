//
//  DishOptionPickerTableViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DishOptionPickerTableViewController.h"
#import "constants.h"
#import "AppModel.h"

@implementation DishOptionPickerTableViewController

@synthesize optionValues = mOptionValues;
@synthesize optionType = mOptionType;

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.optionValues count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [[self.optionValues objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	*pointer = indexPath.row;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)useThisIntPointer:(int *)topLevelPointer{
	pointer = topLevelPointer;
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
	self.optionValues = nil;
    [super dealloc];
}


@end

