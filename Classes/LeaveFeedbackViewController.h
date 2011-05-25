//
//  LeaveFeedbackViewController.h
//  TopDish
//
//  Created by roderic campbell on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol LeaveFeedbackViewControllerDelegate

@required
-(void)feedbackSubmitted;
-(void)feedbackCancelled;

@end

@interface LeaveFeedbackViewController : UIViewController {
	id <LeaveFeedbackViewControllerDelegate, MBProgressHUDDelegate> mFeedbackDelegate;
	
	UITextView	*mFeedbackTextView;
	
	MBProgressHUD	*mHud;
	BOOL			mSuccess;
}

@property (nonatomic, retain) id<LeaveFeedbackViewControllerDelegate> feedbackDelegate;
@property (nonatomic, retain) IBOutlet UITextView *feedbackTextView;

@property (nonatomic, retain) MBProgressHUD		*hud;
@property (nonatomic, assign) BOOL				success;

+(LeaveFeedbackViewController *)viewControllerWithDelegate:(id<LeaveFeedbackViewControllerDelegate>)delegate;

-(IBAction)cancelFeedback;
-(IBAction)submitFeedback;

@end
