//
//  Dish.h
//  TopDish
//
//  Created by roderic campbell on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ObjectWithImage.h"

@class DishComment;
@class Restaurant;
@class Tags;

@interface Dish :  ObjectWithImage  
{
}

@property (nonatomic, retain) NSNumber * posReviews;
@property (nonatomic, retain) NSNumber * dish_id;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * dish_description;
@property (nonatomic, retain) NSNumber * negReviews;
@property (nonatomic, retain) NSSet* comments;
@property (nonatomic, retain) Restaurant * restaurant;
@property (nonatomic, retain) NSSet* tags;

@end


@interface Dish (CoreDataGeneratedAccessors)
- (void)addCommentsObject:(DishComment *)value;
- (void)removeCommentsObject:(DishComment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

- (void)addTagsObject:(Tags *)value;
- (void)removeTagsObject:(Tags *)value;
- (void)addTags:(NSSet *)value;
- (void)removeTags:(NSSet *)value;

@end

