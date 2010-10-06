//
//  Dish.h
//  TopDish
//
//  Created by Roderic Campbell on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Dish :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * dish_name;
@property (nonatomic, retain) UNKNOWN_TYPE dish_super_name;
@property (nonatomic, retain) NSString * dish_description;
@property (nonatomic, retain) NSNumber * negReviews;
@property (nonatomic, retain) NSNumber * posReviews;
@property (nonatomic, retain) NSNumber * dish_id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * dish_photoURL;

@end



