//
//  Dish.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Restaurant.h"


@interface Dish :  NSManagedObject
{
}

@property (nonatomic, retain) NSString * dish_name;
@property (nonatomic, retain) NSString * dish_description;
@property (nonatomic, retain) NSNumber * negReviews;
@property (nonatomic, retain) NSNumber * posReviews;
@property (nonatomic, retain) NSNumber * dish_id;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * dish_photoURL;

@end



