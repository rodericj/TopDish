//
//  ImgCache.h
//  TopDish
//
//  Created by roderic campbell on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// Loosely borrowed from
// http://www.makebetterthings.com/blogs/iphone/image-caching-in-iphone-sdk/


#import <UIKit/UIKit.h>

@interface ImgCache : NSObject {
    
}

- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getImage: (NSString *) ImageURLString;
-(BOOL) doesCacheItemExist:(NSString *)remoteUrlString;

@end
