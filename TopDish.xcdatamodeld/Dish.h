//
//  Dish.h
//  TopDish
//
//  Created by Roderic Campbell on 10/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DishComment;

@interface Dish :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dish_name;
@property (nonatomic, retain) NSString * dish_description;
@property (nonatomic, retain) NSNumber * negReviews;
@property (nonatomic, retain) NSNumber * posReviews;
@property (nonatomic, retain) NSNumber * dish_id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * dish_photoURL;
@property (nonatomic, retain) NSSet* comments;

@end


@interface Dish (CoreDataGeneratedAccessors)
- (void)addCommentsObject:(DishComment *)value;
- (void)removeCommentsObject:(DishComment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

@end

