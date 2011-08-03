//
//  IPadDishTableViewController.m
//  TopDish
//
//  Created by roderic campbell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IPadDishTableViewController.h"
#import "IPadDishDetailViewController.h"

@implementation IPadDishTableViewController


- (void) flipToMap {
    NSLog(@"should push the split view map");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"should push the dish detail view");
    UINavigationController *rightSide;
    rightSide = [self.splitViewController.viewControllers objectAtIndex:1];
    
    ObjectWithImage *selectedObject;
	selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    IPadDishDetailViewController *detailView;
    detailView = [[IPadDishDetailViewController alloc] initWithNibName:@"IPadDishDetailViewController" 
                                                                bundle:nil];
    detailView.thisDish = (Dish *)selectedObject;
    [rightSide popToRootViewControllerAnimated:NO];
    [rightSide pushViewController:detailView animated:NO];
    [detailView release];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
