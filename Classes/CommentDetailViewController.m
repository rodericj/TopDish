//
//  CommentDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "Logger.h"
#import "constants.h"

@implementation CommentDetailViewController

@synthesize	commentDict			= mCommentDict;
@synthesize	userImageView		= mUserImageView;
@synthesize userNameLabel		= mUserNameLabel;
@synthesize commentTextView		= mCommentTextView;

+(CommentDetailViewController *)commentDetailViewWithCommentDict:(NSDictionary *)commentDict {
	CommentDetailViewController *viewController = [[CommentDetailViewController alloc] initWithNibName:@"CommentDetailViewController" 
																								bundle:nil];
	viewController.commentDict = commentDict;
	return [viewController autorelease];
}

-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventCDViewDidAppear];

	self.userNameLabel.text		= [self.commentDict objectForKey:@"creator"];
	self.commentTextView.text	= [self.commentDict objectForKey:@"comment"];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.commentDict		= nil;
	self.userImageView		= nil;
	self.userNameLabel		= nil;
	self.commentTextView	= nil;
    [super dealloc];
}


@end
