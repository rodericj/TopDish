//
//  CommentsTableViewController.h
//  TopDish
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dish.h"
@interface CommentsTableViewController : UITableViewController {
	NSData *mResponseText;
	Dish *mdish;
	UIImageView *commentDirection;
	NSArray *mReviews;
	UITableViewCell *commentCell;
	UITableViewCell *mAddRatingCell;
	UITableViewCell *mPushRestaurantCell;
	UITableViewStyle style;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
}

-(void) refreshFromServer;
@property (nonatomic, assign) IBOutlet UITableViewCell *commentCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *addRatingCell;
@property (nonatomic, assign) IBOutlet UITableViewCell *pushRestaurantCell;
@property (nonatomic, assign) Dish *dish;
@property (nonatomic, retain) UIImageView *commentDirection;
@property (nonatomic, retain) NSArray *reviews;
@property (nonatomic, retain) NSData *responseText;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


-(IBAction) goToRestaurantDetailView; 
-(IBAction) pushRateViewController;

@end
