//
//  AccountView.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountView : UITableViewController {
	UILabel *mUserName;
	UILabel *mUserSince;
	UIView *mTableHeader;
	
	NSMutableArray *mLifestyleTags;
}

@property (nonatomic, retain) IBOutlet UILabel *userName;
@property (nonatomic, retain) IBOutlet UILabel *userSince;
@property (nonatomic, retain) IBOutlet UIView *tableHeader;
@property (nonatomic, retain)  NSMutableArray *lifestyleTags;
@end
