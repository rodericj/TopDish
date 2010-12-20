//
//  ScrollingDishDetailViewController.h
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Dish.h"

@interface ScrollingDishDetailViewController : UIViewController <NSFetchedResultsControllerDelegate> {
	Dish* dish;
	
	IBOutlet UIScrollView *scrollView;
	
	IBOutlet UILabel *dishName;
	IBOutlet UILabel *upVotes;
	IBOutlet UILabel *downVotes;
	IBOutlet UIImageView *dishImage;
	IBOutlet UILabel *description;
	IBOutlet UILabel *restaurantName;
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;

}
-(IBAction) goToRestaurantDetailView; 
-(IBAction) pushRateViewController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) Dish *dish;

@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) UILabel *dishName;
@property (nonatomic, retain) UILabel *restaurantName;
@property (nonatomic, retain) UILabel *upVotes;
@property (nonatomic, retain) UILabel *downVotes;
@property (nonatomic, retain) UIImageView *dishImage;
@property (nonatomic, retain) UILabel *description;

@end
