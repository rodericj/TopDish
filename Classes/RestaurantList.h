//
//  RestaurantList.h
//  TopDish
//
//  Created by roderic campbell on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"

@interface RestaurantList : UITableViewController  <MyCLControllerDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>{

    NSFetchedResultsController *mFetchedResultsController;
	NSManagedObjectContext *mManagedObjectContext;
	UITableViewCell				*mTvCell;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;


@end
