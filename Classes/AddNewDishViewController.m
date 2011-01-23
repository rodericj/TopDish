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
#import "TopDishAppDelegate.h"
#import "AppModel.h"
#import "constants.h"
#import "ASIFormDataRequest.h"
#import "DishOptionPickerTableViewController.h"

@implementation AddNewDishViewController
@synthesize dishNameTextField = mDishNameTextField;
@synthesize restaurantNameLabel = mRestaurantNameLabel;
@synthesize restaurant = mRestaurant;
@synthesize dish = mDish;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize dishImageFromPicker = mDishImageFromPicker;
@synthesize hasPicture = mHasPicture;
@synthesize dishId = mDishId;
@synthesize mealTypePickerButton = mMealTypePickerButton;
@synthesize pricePickerButton = mPricePickerButton;
@synthesize pickerView = mPickerView;
@synthesize pickerArray = mPickerArray;
@synthesize selectedPrice = mSelectedPrice;
@synthesize selectedMealType = mSelectedMealType;

@synthesize priceLabel = mPriceLabel;
@synthesize mealTypeLabel = mMealLabel;

-(void)viewDidLoad{
	self.restaurantNameLabel.text = [self.restaurant objName];
	self.hasPicture = NO;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[AppModel instance].user objectForKey:keyforauthorizing] == nil)
		[[(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:kAccountsTab];
	else if (!self.hasPicture)
	{
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
			
			[imagePicker setCameraOverlayView:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
			
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
	if (self.selectedMealType) 
		self.mealTypeLabel.text = self.selectedMealType;
	if(self.selectedPrice)
		self.priceLabel.text = self.selectedPrice;
}

-(IBAction)pickPrice {
	NSLog(@"pick a price");
	DishOptionPickerTableViewController *d = [[DishOptionPickerTableViewController alloc] init];
	[d setOptionValues:[NSArray arrayWithObjects:@"$1 or less", @"Under $5", @"$5-$10",  nil]];
	[d setOptionType:kPriceType];
	[self.navigationController pushViewController:d animated:YES];
	[d release];
}

-(IBAction)pickMealType {
	NSLog(@"show meal type picker");
	DishOptionPickerTableViewController *d = [[DishOptionPickerTableViewController alloc] init];
	[d setOptionValues:[NSArray arrayWithObjects:@"Breakfast", @"Lunch", @"Dinner", nil]];
	[d setOptionType:kMealType];
	[self.navigationController pushViewController:d animated:YES];
	[d release];
}

-(IBAction)addDish {
	if(self.dishNameTextField.text){
		//Create Dish
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addDish"]];
		
		NSLog(@"this is what we are sending for add a dish: url%@\n, name %@\n description %@\n resto id %@\n apiKey %@", 
			  [url absoluteURL], 
			  self.dishNameTextField.text,
			  @"this is the description",
			  [self.restaurant restaurant_id] ,
			  [[[AppModel instance] user] objectForKey:keyforauthorizing]);
		
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:self.dishNameTextField.text forKey:@"name"];
		[request setPostValue:@"hardcoded iPhone description" forKey:@"description"];
		[request setPostValue:[NSString stringWithFormat:@"%@", [self.restaurant restaurant_id]] forKey:@"restaurantId"];		
		[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[request setPostValue:self.selectedPrice forKey:@"price"];
		[request setPostValue:self.selectedMealType	forKey:@"mealType"];
				
		// Upload an NSData instance
		[request setDelegate:self];
		[request startAsynchronous];
		
	}
	else{
		NSLog(@"give the dish a name");
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching binary data
	NSString *responseText = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
	
	//Create the dish in our database
	//Add Dish Name
	Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
														   inManagedObjectContext:self.managedObjectContext];
	[thisDish setDish_id:[NSNumber numberWithShort:[responseText intValue]]];
	[thisDish setObjName:self.dishNameTextField.text];
	[thisDish setRestaurant:self.restaurant];
	[thisDish setObjName:self.dishNameTextField.text];
	
	//Add location from the restaurant here....
	[thisDish setLatitude:[[thisDish restaurant] latitude]];
	[thisDish setLongitude:[[thisDish restaurant] longitude]];
	
	//self.dish = thisDish;
	
	//Push the RateDishViewController
	RateDishViewController *rateDish = [[RateDishViewController alloc] init];
	[rateDish setDish:thisDish];
	[thisDish setImageData:UIImagePNGRepresentation([self.dishImageFromPicker image])];
	[self.navigationController pushViewController:rateDish animated:YES];
	
	[rateDish release];
	[thisDish release];
	
	//Now let's send the picture
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
	NSLog(@"submitting the image %@", [url absoluteURL]);
	ASIFormDataRequest *newImageRequest = [ASIFormDataRequest requestWithURL:url];
	[newImageRequest setDidFinishSelector:@selector(imageSubmissionSuccess:)];
	[newImageRequest setDidFailSelector:@selector(imageSubmissionFailure:)];
	[newImageRequest setData:UIImagePNGRepresentation(self.dishImageFromPicker.image) forKey:@"photo"];
	[newImageRequest setPostValue:responseText forKey:@"dishId"];
	[newImageRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	
	[newImageRequest setDelegate:nil];
	[newImageRequest startAsynchronous];
	
	//NSLog(@"response string %@  \nand of course %@", responseString, responseText);
}
-(void)imageSubmissionSuccess:(ASIHTTPRequest *) request
{
	NSLog(@"request to submit image succeeded");
}

-(void)imageSubmissionFailure:(ASIHTTPRequest *) request
{
	NSLog(@"request to submit image failed");
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"error %@", error);
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
	self.hasPicture = YES;
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
