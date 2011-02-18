//
//  RestaurantListTableViewDelegate.h
//  TopDish
//
//  Created by roderic campbell on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantListTableViewDelegate : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {

	UITableViewCell				*tvCell;
	UINavigationController		*mNavigationController;

    NSFetchedResultsController *mFetchedResultsController;
    NSManagedObjectContext *managedObjectContext_;
	
}
@property (nonatomic, retain) UINavigationController *topNavigationController;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
