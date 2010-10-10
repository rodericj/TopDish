//
//  ScrollingDishDetailViewController.h
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Dish.h"

@interface ScrollingDishDetailViewController : UIViewController {
	Dish* dish;
	
	IBOutlet UIScrollView *scrollView;
	
	IBOutlet UILabel *dishName;
	IBOutlet UILabel *upVotes;
	IBOutlet UILabel *downVotes;
	IBOutlet UIImageView *dishImage;
}
@property (nonatomic, retain) Dish *dish;

@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) UILabel *dishName;
@property (nonatomic, retain) UILabel *upVotes;
@property (nonatomic, retain) UILabel *downVotes;
@property (nonatomic, retain) UIImageView *dishImage;

@end
