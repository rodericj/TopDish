//
//  DishTableViewer.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AddNewDish.h"

@interface DishTableViewer : UITableViewController {

	UITableViewCell *tvCell;
	AddNewDish *mAddItemCell;
@protected
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
	NSMutableData *_responseData;

}
@property (nonatomic, retain) IBOutlet AddNewDish *addItemCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableData *_responseData;

-(void) processIncomingNetworkText:(NSString *)responseText;

@end
