//
//  LoginModalView.h
//  TopDish
//
//  Created by roderic campbell on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginButton.h"

@protocol LoginModalViewDelegate

@required
-(void)notNowButtonPressed;
-(void)loginComplete;
-(void)loginStarted;
@end

@interface LoginModalView : UIViewController {
	FBLoginButton *mFbLoginButton;
	id<LoginModalViewDelegate> mDelegate;
}

@property (nonatomic, retain) IBOutlet FBLoginButton *fbLoginButton;
@property (nonatomic, assign) id<LoginModalViewDelegate> delegate;

-(IBAction)notNowButtonPressed;
-(IBAction)fbButtonClick:(id)sender;
@end