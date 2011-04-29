//
//  LeaveFeedbackViewController.m
//  TopDish
//
//  Created by roderic campbell on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LeaveFeedbackViewController.h"
#import "constants.h"
#import "ASIFormDataRequest.h"
#import "AppModel.h"

@implementation LeaveFeedbackViewController

@synthesize feedbackDelegate = mFeedbackDelegate;
@synthesize feedbackTextView = mFeedbackTextView;

+(LeaveFeedbackViewController *)viewControllerWithDelegate:(id<LeaveFeedbackViewControllerDelegate>)delegate{
	LeaveFeedbackViewController *viewController = [[[LeaveFeedbackViewController alloc] init] autorelease];
	viewController.feedbackDelegate = delegate;
	return viewController;
}

-(IBAction)cancelFeedback {
	[self.feedbackDelegate feedbackCancelled];
}

-(IBAction)submitFeedback {
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/feedback"]];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:self.feedbackTextView.text forKey:@"comment"];

	[request setDelegate:[AppModel instance]];
	[request startAsynchronous];
	
	[self.feedbackDelegate feedbackSubmitted];
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
	self.feedbackTextView = nil;
    [super dealloc];
}


@end
