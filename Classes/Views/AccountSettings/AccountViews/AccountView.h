//
//  AccountView.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoggedInLoggedOutGate.h"
#import "Facebook.h"

@interface AccountView : UITableViewController <FBRequestDelegate, FBSessionDelegate> {
	UILabel *mUserName;
	UILabel *mUserSince;
	UIView *mTableHeader;
	UIImageView *mUserImage;
	
	FBRequest *mImageRequest;
	
	NSMutableArray *mLifestyleTags;
}

@property (nonatomic, retain) IBOutlet UILabel *userName;
@property (nonatomic, retain) IBOutlet UILabel *userSince;
@property (nonatomic, retain) IBOutlet UIView *tableHeader;
@property (nonatomic, retain) IBOutlet UIImageView *userImage;
@property (nonatomic, retain)  NSMutableArray *lifestyleTags;
@property (nonatomic, retain) FBRequest *imageRequest;
@end