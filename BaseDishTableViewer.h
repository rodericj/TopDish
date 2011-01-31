//
//  BaseDishTableViewer.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ObjectWithImage.h"

@interface BaseDishTableViewer : UITableViewController {

	NSString					*mEntityTypeString;
	UITableViewCell				*mTvCell;
	UITableViewCell				*mAddItemCell;
@protected
    NSFetchedResultsController *mFetchedResultsController;
    NSManagedObjectContext *mManagedObjectContext;
	NSMutableData *mResponseData;
	NSURLConnection *mConn;

}

@property (nonatomic, retain) NSString *entityTypeString;
@property (nonatomic, retain) IBOutlet UITableViewCell *addItemCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *tvCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *conn;

-(void) processIncomingNetworkText:(NSString *)responseText;
-(void) decorateFetchRequest:(NSFetchRequest *)request;
-(void) pushDishViewController:(ObjectWithImage *) selectedObject;
-(UITableViewCell *)tableView:(UITableView *)tableView dishCellAtIndexPath:(NSIndexPath *)indexPath;

@end
