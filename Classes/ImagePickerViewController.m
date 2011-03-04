    //
//  ImagePickerViewController.m
//  TopDish
//
//  Created by roderic campbell on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "constants.h"

@implementation ImagePickerViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.toolbar setBackgroundColor:[UIColor redColor]];
	if([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear]){
		DLog(@"Back camera exists");
	}
	else{
		DLog(@"Back camera does not exist");
	}
	if([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront]){
		DLog(@"Front camera exists");
	}
	else{
		DLog(@"Front camera does not exist");
	}
 //[self setSourceType:UIImagePickerControllerSourceTypeCamera];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}


@end
