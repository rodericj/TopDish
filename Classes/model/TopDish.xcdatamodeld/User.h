//
//  User.h
//  TopDish
//
//  Created by roderic campbell on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface User :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * emailAddress;

@end



