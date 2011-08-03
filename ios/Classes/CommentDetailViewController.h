//
//  CommentDetailViewController.h
//  TopDish
//
//  Created by roderic campbell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentDetailViewController : UIViewController {
	NSDictionary		*mCommentDict;
	
	UIImageView			*mUserImageView;
	UILabel				*mUserNameLabel;
	UITextView			*mCommentTextView;
}

@property (nonatomic, retain)			NSDictionary	*commentDict;
@property (nonatomic, retain) IBOutlet	UIImageView		*userImageView;
@property (nonatomic, retain) IBOutlet	UILabel			*userNameLabel;
@property (nonatomic, retain) IBOutlet	UITextView		*commentTextView;

+(CommentDetailViewController *)commentDetailViewWithCommentDict:(NSDictionary *)commentDict;
@end
