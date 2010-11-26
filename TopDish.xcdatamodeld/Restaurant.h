//
//  Restaurant.h
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Dish;

@interface Restaurant :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * addressLine2;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * restaurant_description;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * dateDefined;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * restaurant_photoURL;
@property (nonatomic, retain) NSNumber * restaurant_id;
@property (nonatomic, retain) NSString * restaurant_name;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * addressLine1;
@property (nonatomic, retain) NSSet* restaurant_dish;

@end


@interface Restaurant (CoreDataGeneratedAccessors)
- (void)addRestaurant_dishObject:(Dish *)value;
- (void)removeRestaurant_dishObject:(Dish *)value;
- (void)addRestaurant_dish:(NSSet *)value;
- (void)removeRestaurant_dish:(NSSet *)value;

@end

