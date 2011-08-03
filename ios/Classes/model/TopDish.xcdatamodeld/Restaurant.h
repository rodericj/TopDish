//
//  Restaurant.h
//  TopDish
//
//  Created by roderic campbell on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ObjectWithImage.h"

@class Dish;

@interface Restaurant :  ObjectWithImage  
{
}

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * restaurant_id;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * restaurant_description;
@property (nonatomic, retain) NSString * addressLine1;
@property (nonatomic, retain) NSString * addressLine2;
@property (nonatomic, retain) NSDate * dateDefined;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSSet* restaurant_dish;

@end


@interface Restaurant (CoreDataGeneratedAccessors)
- (void)addRestaurant_dishObject:(Dish *)value;
- (void)removeRestaurant_dishObject:(Dish *)value;
- (void)addRestaurant_dish:(NSSet *)value;
- (void)removeRestaurant_dish:(NSSet *)value;

@end

