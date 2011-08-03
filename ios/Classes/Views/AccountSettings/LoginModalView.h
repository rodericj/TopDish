//
//  LoginModalView.h
//  TopDish
//
//  Created by roderic campbell on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginButton.h"

@interface LoginModalView : UIViewController {
	FBLoginButton *mFbLoginButton;
}

@property (nonatomic, retain) IBOutlet FBLoginButton *fbLoginButton;

-(IBAction)okButtonPressed;
-(IBAction)fbButtonClick:(id)sender;
@end