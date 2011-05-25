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


@implementation LeaveFeedbackViewController

@synthesize feedbackDelegate = mFeedbackDelegate;
@synthesize feedbackTextView = mFeedbackTextView;

@synthesize hud				= mHud;

+(LeaveFeedbackViewController *)viewControllerWithDelegate:(id<LeaveFeedbackViewControllerDelegate>)delegate{
	LeaveFeedbackViewController *viewController = [[[LeaveFeedbackViewController alloc] init] autorelease];
	viewController.feedbackDelegate = delegate;
	return viewController;
}

-(IBAction)cancelFeedback {
	[self.feedbackDelegate feedbackCancelled];
}

-(IBAction)submitFeedback {
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/sendUserFeedback"]];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	NSString *feedbackString = [NSString stringWithFormat:@"%@ \n\nAuthKey:%@", 
								self.feedbackTextView.text, 
								[[[AppModel instance] user] objectForKey:keyforauthorizing]];
	NSLog(@"feedback is %@", feedbackString);
	
	[request setPostValue:feedbackString forKey:@"feedback"];	
	[request setDelegate:self];
	[request startAsynchronous];
	
}

#pragma mark - Network responses
- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responseString = [request responseString];

	DLog(@"didFinishLoading dishDetailViewController start");
	
	SBJSON *parser = [SBJSON new];
	NSError *error;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseString 
															error:&error];
	DLog(@"response is %@", responseAsDictionary);
	[self.feedbackDelegate feedbackSubmitted];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	DLog(@"error %@", [request error]);
	self.hud.labelText = @"Error while Submitting feedback";
	[self.hud hide:YES afterDelay:2]; 
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
