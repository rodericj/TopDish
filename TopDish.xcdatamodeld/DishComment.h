//
//  DishComment.h
//  TopDish
//
//  Created by roderic campbell on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Dish;

@interface DishComment :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * reviewer_name;
@property (nonatomic, retain) NSNumber * isPositive;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * reviewer_id;
@property (nonatomic, retain) Dish * dish;

@end



