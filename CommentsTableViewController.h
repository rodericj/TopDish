//
//  CommentsTableViewController.h
//  TopDish
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentsTableViewController : UITableViewController {
	NSNumber *dishId;
	NSData *_responseText;
	
	NSArray *reviews;
	UITableViewCell *commentCell;

	NSURLRequest *request;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

-(void) refreshFromServer;
@property (nonatomic, assign) IBOutlet UITableViewCell *commentCell;

@property (nonatomic, retain)  NSNumber *dishId;
@property (nonatomic, retain)  NSArray *reviews;
@property (nonatomic, retain)  NSData *_responseText;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
