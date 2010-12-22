//
//  AddNewDishViewController.m
//  TopDish
//
//  Created by roderic campbell on 12/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddNewDishViewController.h"
#import "RateDishViewController.h"
#import "ImagePickerViewController.h"
#import "Dish.h"

@implementation AddNewDishViewController
@synthesize dishNameTextField = mDishNameTextField;
@synthesize restaurantNameLabel = mRestaurantNameLabel;
@synthesize restaurant = mRestaurant;
@synthesize dish = mDish;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize dishImageFromPicker = mDishImageFromPicker;


-(void)viewDidLoad{
	self.restaurantNameLabel.text = [self.restaurant objName];
	
	//To use an image picker controller containing its default controls, perform these steps:

	//	1. Verify that the device is capable of picking content from the desired source. Do this calling 
	//the isSourceTypeAvailable: class method, providing a constant from the 
	//“UIImagePickerControllerSourceType” enum.
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setAllowsEditing:YES];

	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		//then push the imagepicker
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
		[imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
	}
	else {
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	
	[self presentModalViewController:imagePicker animated:YES];
	
	//	5. When the user taps a button to pick a newly-captured or saved image or movie, or 
	//cancels the operation, dismiss the image picker using your delegate object. For 
	//newly-captured media, your delegate can then save it to the Camera Roll on the device. 
	//For previously-saved media, your delegate can then use the image data according to the 
	//purpose of your app.
	
}
-(IBAction)addDish {
	if(self.dishNameTextField.text){
		//Create Dish
		Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
															   inManagedObjectContext:self.managedObjectContext];
		NSLog(@"dish %@", thisDish);
		//Add Dish Name
		[thisDish setRestaurant:self.restaurant];
		[thisDish setObjName:self.dishNameTextField.text];
		
		//Add location from the restaurant here....
		[thisDish setLatitude:[[thisDish restaurant] latitude]];
		[thisDish setLongitude:[[thisDish restaurant] longitude]];
		
		RateDishViewController *rateDish = [[RateDishViewController alloc] init];
		[rateDish setDish:thisDish];
		[thisDish setImageData:UIImagePNGRepresentation([self.dishImageFromPicker image])];
		[self.navigationController pushViewController:rateDish animated:YES];
		[rateDish release];
		self.dish = thisDish;
		[thisDish release];
	}
	else{
		NSLog(@"give the dish a name");
	}
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

#pragma mark -
#pragma mark delegate functions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//self.dishImageFromPicker = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	[self.dishImageFromPicker setImage:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	NSLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {
	self.restaurant = nil;
	self.dishNameTextField = nil;
	self.restaurantNameLabel = nil;
    [super dealloc];
}


@end
