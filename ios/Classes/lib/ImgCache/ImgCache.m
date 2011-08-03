//
//  ImgCache.m
//  TopDish
//
//  Created by roderic campbell on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImgCache.h"
#import "constants.h"
#define TMP NSTemporaryDirectory()

@implementation ImgCache
-(NSString *)pathFromURLString:(NSString *)remoteUrlString {
    //generating unique name for the cached file with ImageURLString so you can retrive it back
    NSMutableString *tmpStr = [NSMutableString stringWithString:remoteUrlString];
    [tmpStr replaceOccurrencesOfString:@"/" withString:@"-" options:1 range:NSMakeRange(0, [tmpStr length])];
    
    NSString *filename = [NSString stringWithFormat:@"%@",tmpStr];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    return uniquePath;
}

- (void) cacheImage: (NSString *) ImageURLString
{
    NSURL *ImageURL = [NSURL URLWithString: ImageURLString];

    NSString *uniquePath = [self pathFromURLString:ImageURLString];
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        NSData *data = [NSData dataWithContentsOfURL:ImageURL];
        UIImage *image = [UIImage imageWithData:data];
        [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
    }
}

-(BOOL) doesCacheItemExist:(NSString *)remoteUrlString {
    NSString *uniquePath = [self pathFromURLString:remoteUrlString];

    return [[NSFileManager defaultManager] fileExistsAtPath: uniquePath];
}

- (UIImage *) getImage: (NSString *) ImageURLString
{
    NSMutableString *tmpStr = [NSMutableString stringWithString:ImageURLString];
    [tmpStr replaceOccurrencesOfString:@"/" withString:@"-" options:1 range:NSMakeRange(0, [tmpStr length])];
    
    NSString *filename = [NSString stringWithFormat:@"%@",tmpStr];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        NSData *data = [NSData dataWithContentsOfFile:uniquePath];
        image = [UIImage imageWithData:data];
    }
    else
    {
        // get a new one
        DLog(@"get new image %@", ImageURLString);

        [self cacheImage: ImageURLString];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:uniquePath]];
        image = [UIImage imageWithData:data];
        
    }
    
    return image;
}

@end