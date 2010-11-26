//
//  RestaurantDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"
#import "DishTableViewer.h"

@interface RestaurantDetailViewController : DishTableViewer {

	Restaurant *restaurant;
	NSMutableData *_responseData;
	
	IBOutlet UIView *restaurantHeader;
	IBOutlet UILabel *restaurantName;
	IBOutlet UILabel *restaurantAddress;
	IBOutlet UILabel *restaurantPhone;
	
//@private
//    NSFetchedResultsController *fetchedResultsController_;
//    NSManagedObjectContext *managedObjectContext_;
	

}

-(void) processIncomingNetworkText:(NSString *)responseText;

@property (nonatomic, retain) Restaurant *restaurant;
@property (nonatomic, retain) NSMutableData *_responseData;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
