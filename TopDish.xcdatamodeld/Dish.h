//
//  Dish.h
//  TopDish
//
//  Created by Roderic Campbell on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DishComment;
@class Restaurant;

@interface Dish :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dish_photoURL;
@property (nonatomic, retain) NSNumber * dish_id;
@property (nonatomic, retain) NSString * dish_description;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * dish_name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * negReviews;
@property (nonatomic, retain) NSNumber * posReviews;
@property (nonatomic, retain) NSSet* comments;
@property (nonatomic, retain) Restaurant * restaurant;

@end


@interface Dish (CoreDataGeneratedAccessors)
- (void)addCommentsObject:(DishComment *)value;
- (void)removeCommentsObject:(DishComment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

@end

