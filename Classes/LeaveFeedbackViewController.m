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
#import "JSON.h"
#import "FeedbackStringProcessor.h"

@implementation LeaveFeedbackViewController

@synthesize feedbackDelegate = mFeedbackDelegate;
@synthesize feedbackTextView = mFeedbackTextView;

@synthesize hud				= mHud;
@synthesize success			= mSuccess;

+(LeaveFeedbackViewController *)viewControllerWithDelegate:(id<LeaveFeedbackViewControllerDelegate>)delegate{
	LeaveFeedbackViewController *viewController = [[[LeaveFeedbackViewController alloc] init] autorelease];
	viewController.feedbackDelegate = delegate;
	return viewController;
}

-(IBAction)cancelFeedback {
	[self.feedbackDelegate feedbackCancelled];
}

-(IBAction)submitFeedback {
	[FeedbackStringProcessor SendFeedback:self.feedbackTextView.text delegate:self];
	
	self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.hud.labelText = @"Submitting Feedback...";
	self.hud.delegate = self;
	self.view.userInteractionEnabled = NO;
}

#pragma mark - Network responses
- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responseString = [request responseString];
	self.hud.labelText = @"Thanks for the feedback";

	DLog(@"didFinishLoading start");
	
	//Send feedback if broken
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		self.hud.labelText = message;
		[self.hud hide:YES afterDelay:3];
		return;
	}
	
	SBJSON *parser = [SBJSON new];
	NSError *error;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseString 
															error:&error];
	[parser release];
	DLog(@"response is %@", responseAsDictionary);
	[self.hud hide:YES afterDelay:2];
	self.success = TRUE;

}
- (void)hudWasHidden {
	if (self.success)
		[self.feedbackDelegate feedbackSubmitted];
	self.view.userInteractionEnabled = YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	DLog(@"error %@", [request error]);
	self.hud.labelText = @"Error while Submitting feedback\nTry again in a minute.";
	[self.hud hide:YES afterDelay:4]; 
}

#pragma mark - general memory stuff

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
	self.hud = nil;
    [super dealloc];
}


@end
