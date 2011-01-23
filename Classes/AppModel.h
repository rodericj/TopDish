//
//  AppModel.h
//  TopDish
//
//  Created by roderic campbell on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppModel : NSObject {
	NSMutableDictionary *mUser;
}

@property (nonatomic, retain) NSMutableDictionary *user;
+(AppModel *)instance;
@end
