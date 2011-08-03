//
//  DishTableViewCell.h
//  TopDish
//
//  Created by roderic campbell on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DishTableViewCell : UITableViewCell {
	UIImageView		*mDishImageView;
	UILabel			*mDishName;
	UILabel			*mRestaurantName;
	UILabel			*mMealType;
	UILabel			*mDistance;
	UILabel			*mUpVotes;
	UILabel			*mDownVotes;
	UILabel			*mPriceNumber;

}	

@property (nonatomic,retain) IBOutlet UIImageView		*dishImageView;
@property (nonatomic,retain) IBOutlet UILabel			*dishName;
@property (nonatomic,retain) IBOutlet UILabel			*restaurantName;
@property (nonatomic,retain) IBOutlet UILabel			*mealType;
@property (nonatomic,retain) IBOutlet UILabel			*distance;
@property (nonatomic,retain) IBOutlet UILabel			*upVotes;
@property (nonatomic,retain) IBOutlet UILabel			*downVotes;
@property (nonatomic,retain) IBOutlet UILabel			*priceNumber;
@end
