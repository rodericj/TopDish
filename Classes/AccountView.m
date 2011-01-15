//
//  AccountView.m
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountView.h"


@implementation AccountView

@synthesize userName = mUserName;
@synthesize userSince = mUserSince;
@synthesize tableHeader = mTableHeader;
@synthesize lifestyleTags = mLifestyleTags;

enum {
    kListAdderSectionIndexTotal = 0,
    kAddLifestyleTags,
    kLifestyleTagsList,
    kListAdderSectionIndexCount
};

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	[self.tableView setTableHeaderView:self.tableHeader];
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.userName.text = @"Roderic Campbell";
	self.userSince.text = @"User Since: Dec 12, 2010";
}


#pragma mark -
#pragma mark Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case kLifestyleTagsList:
			return @"Cuisines";
		case kAddLifestyleTags:
			return @"";
		default:
			return @"Dishes Reviewed";
	}
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//Individual settings
	//dishes reviewed
    return 2;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result;
	
#pragma unused(tv)
    assert(tv == self.tableView);
    assert(indexPath.section < kListAdderSectionIndexCount);
    assert(indexPath.row < ((indexPath.section == kLifestyleTagsList) ? [self.lifestyleTags count] : 1));
    
    switch (indexPath.section) {
        default:
            assert(NO);
            // fall through
        case kListAdderSectionIndexTotal: {
            result = UITableViewCellEditingStyleNone;
        } break;
        case kAddLifestyleTags: {
            result = UITableViewCellEditingStyleInsert;
        } break;
        case kLifestyleTagsList: {
            // We don't allow the user to delete the last cell.
            if ([self.lifestyleTags count] == 1) {
                result = UITableViewCellEditingStyleNone;
            } else {
                result = UITableViewCellEditingStyleDelete;
            }
        } break;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == kLifestyleTagsList) {
		return [self.lifestyleTags count];
	}
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    return cell;
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
	self.userName = nil;
	self.userSince = nil;
	self.tableHeader = nil;
}


@end

