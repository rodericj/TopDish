//
//  Restaurant.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Restaurant :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * restaurant_name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * restaurant_photoURL;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * restaurant_description;

@end



