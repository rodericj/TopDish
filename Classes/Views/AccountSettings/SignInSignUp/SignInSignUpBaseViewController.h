//
//  SignInSIgnUpBaseViewController.h
//  TopDish
//
//  Created by roderic campbell on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoggedInLoggedOutGate.h"
#import "FBConnect.h"
#import "FBLoginButton.h"
#import "constants.h"


@interface SignInSignUpBaseViewController : UIViewController <UIAlertViewDelegate,
											FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>{	
}

@property (nonatomic, retain) IBOutlet FBLoginButton *fbLoginButton;

-(IBAction)fbButtonClick:(id)sender;

@end
