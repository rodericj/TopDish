//
//  CustomNSURLConnection.h
//  TopDish
//
//  Created by roderic campbell on 4/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLConnection (hasCopyWithZone)

- (id)copyWithZone:(NSZone *)zone;

@end
