//
//  RootViewController.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController < NSFetchedResultsControllerDelegate> {
    //NSMutableArray *tableData;
    
	UIImageView *bgImage;
    UITableView *theTableView;
    UISearchBar *theSearchBar;

	UITableViewCell *tvCell;
	NSData *_responseText;

@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}
-(void) updateSettings:(NSDictionary *)settings;


@property (nonatomic, retain) IBOutlet UIImageView *bgImage;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSData *_responseText;


//@property(retain) NSMutableArray *tableData;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) IBOutlet UISearchBar *theSearchBar;


@end
