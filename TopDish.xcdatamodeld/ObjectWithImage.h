//
//  ObjectWithImage.h
//  TopDish
//
//  Created by roderic campbell on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface ObjectWithImage :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSData * ImageDataThumb;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * objName;

@end



