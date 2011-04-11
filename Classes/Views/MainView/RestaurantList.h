//
//  RestaurantList.h
//  TopDish
//
//  Created by roderic campbell on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"
#import "IncomingProcessor.h"

@interface RestaurantList : UITableViewController  <NSFetchedResultsControllerDelegate, 
UISearchBarDelegate,
IncomingProcessorDelegate>{

    NSFetchedResultsController	*mFetchedResultsController;
	NSManagedObjectContext		*mManagedObjectContext;
	UITableViewCell				*mTvCell;

	UIView						*mTableHeaderView;
	UISearchBar					*mSearchBar;
	NSString					*mCurrentSearchTerm;
	int							mCurrentSearchDistance;
	
	NSMutableData *mResponseData;
	
	NSMutableDictionary *mConnectionLookup;

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;

@property (nonatomic, retain) IBOutlet UIView *tableHeaderView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSString *currentSearchTerm;
@property (nonatomic, assign) int currentSearchDistance;

@property (nonatomic, retain) NSMutableData *responseData;

@end
