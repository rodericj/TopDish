//
//  RestaurantDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "constants.h"
#import "JSON.h"
#import "RestaurantAnnotation.h"
#import "FeedbackStringProcessor.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "AppModel.h"

#import "UIImage+Resize.h"
#import "MWPhotoBrowser.h"

#import "Logger.h"

#define kFlagRequestObject 0

@implementation RestaurantDetailViewController
@synthesize restaurant;
@synthesize restaurantHeader		= mRestaurantHeader;
@synthesize mapRow					= mMapRow;
@synthesize restaurantName			= mRestaurantName;
@synthesize restaurantAddress		= mRestaurantAddress;
@synthesize restaurantPhone			= mRestaurantPhone;
@synthesize restaurantImage			= mRestaurantImage;
@synthesize mapView					= mMapView;
@synthesize mapOverlay				= mMapOverlay;
@synthesize mapButton				= mMapButton;

@synthesize cameraImage				= mCameraImage;
@synthesize newPicture				= mNewPicture;
@synthesize footerView				= mFooterView;

@synthesize flagView				= mFlagView;
@synthesize menuSectionHeaderView	= mMenuSectionHeaderView;

@synthesize hud						= mHud;

@synthesize urlImageArray           = mUrlImageArray;

#pragma mark -
#pragma mark networking

-(void)processIncomingNetworkText:(NSString *)responseText{
	DLog(@"processing incoming network text %@", responseText);
	
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[parser release];
		return;
	}
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];

	NSPersistentStoreCoordinator *coord = [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];

	IncomingProcessor *proc = [IncomingProcessor processorWithPersistentStoreCoordinator:coord Delegate:self];
	[[[AppModel instance] queue] addOperation:[proc taskWithData:responseTextStripped]];
	
	[parser release];
	
}

#pragma mark -
#pragma mark fetch handling
-(NSPredicate *)restaurantDetailFilter {
	return [NSPredicate predicateWithFormat: @"%K = %@", 
			@"restaurant.restaurant_id", [restaurant restaurant_id]];
}
-(void) populatePredicateArray:(NSMutableArray *)filterPredicateArray{
	//do nothing
}
#pragma mark -
#pragma mark View lifecycle
- (void) setUpSpecificView {
	self.currentSearchDistance = kOneMileInMeters;

	[self.restaurantName setText:[restaurant objName]];
	
	[self.restaurantPhone setTitle:[restaurant phone] 
						  forState:UIControlStateNormal];
	[self.restaurantAddress setText:[restaurant addressLine1]];
//    NSArray *recognizers = [self.restaurantImage gestureRecognizers];
//    
//    //This feels gross, but I have to make sure there are not extra recognizers since this may be called multiple times
//    for (UIGestureRecognizer *recognizer in recognizers){
//        [self.restaurantImage removeGestureRecognizer:recognizer];
//    }
    
	if( [[restaurant photoURL] length] > 0 ){
        UITapGestureRecognizer *tapPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhotoViewer)];
        
        [self.restaurantImage addGestureRecognizer:tapPhoto];
        self.restaurantImage.userInteractionEnabled = YES;
        [tapPhoto release];

		if (![[AppModel instance] doesCacheItemExist:restaurant.photoURL size:85]) {
			dispatch_queue_t downloadQueue = dispatch_queue_create("com.topdish.imagedownload", NULL);
			//dispatch_retain(downloadQueue);
			
			//On background thread, download the image synchronously.
			dispatch_async(downloadQueue, ^{
				//Set up URL and download image (all in the background)
				UIImage *image = [[AppModel instance] getImage:restaurant.photoURL size:85];				
				//On the main thread, update the appropriate cell and the core data object
				dispatch_async(dispatch_get_main_queue(), ^{
					self.restaurantImage.image = image;
                    [self setUpSpecificView];
				});
				
			});
			dispatch_release(downloadQueue);
		}
		else
			self.restaurantImage.image = [[AppModel instance] getImage:restaurant.photoURL size:85];
	}	

	else {
		self.restaurantImage.image = [UIImage imageNamed:@"no_rest_img.jpg"];
        UITapGestureRecognizer *tapPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyPhoto:)];
        [self.restaurantImage addGestureRecognizer:tapPhoto];
        self.restaurantImage.userInteractionEnabled = YES;
        [tapPhoto release];

    }

        
    
	self.restaurantHeader.selectionStyle = UITableViewCellSelectionStyleNone;
	self.tableView.tableHeaderView = self.restaurantHeader;
	
}

-(void)reloadView {
    DLog(@"just added a dish, time to refresh");
	[self networkQuery:[NSString stringWithFormat:@"%@/api/restaurantDetail?id[]=%@", NETWORKHOST, [restaurant restaurant_id]]];	
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = kTopDishBlue;
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    [Logger logEvent:kEventRDViewDidAppear];

    [self reloadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];

	self.menuSectionHeaderView.backgroundColor = kTopDishBlue;
	//hit the network and refresh our data
	
	self.view.backgroundColor = kTopDishBackground;
	
	[self.view addSubview:self.mapOverlay];
	CGRect overlay = self.mapOverlay.frame;
	overlay.origin.y = -overlay.size.height + 20;
	self.mapOverlay.frame = overlay;
	UITapGestureRecognizer *touchGesture = [[UITapGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handleTapGesture:)];
    [self.mapOverlay addGestureRecognizer:touchGesture];
    [touchGesture release];
	
	UITapGestureRecognizer *takePictureTouchGesture = [[UITapGestureRecognizer alloc]
											initWithTarget:self action:@selector(takePicture:)];
    [self.cameraImage addGestureRecognizer:takePictureTouchGesture];
    [takePictureTouchGesture release];
	
	//Set up the map
	CLLocationCoordinate2D center;
	center.latitude = [[self.restaurant latitude] floatValue];
	center.longitude = [[self.restaurant longitude] floatValue];
	MKCoordinateRegion m;
	m.center = center;
	
	MKCoordinateSpan span;
	span.latitudeDelta = .003;
	span.longitudeDelta = .003;
	
	//Set up the span
	m.span = span;
	[self.mapView setRegion:m animated:YES];
	
	RestaurantAnnotation *thisAnnotation = [[RestaurantAnnotation alloc] initWithCoordinate:center];
	
	[self.mapView addAnnotation:thisAnnotation];
	[thisAnnotation release];
		
	[self.mapOverlay setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"restaurant_back.png"]]];

	self.title = [self.restaurant objName];
	self.tableView.tableFooterView = self.footerView;

	}

#pragma mark -
#pragma mark Table view classes overridden 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView{
	return 1;
}
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    NSData *thisResponseData = [self.connectionLookup objectForKey:theConnection];
    
	NSString *responseText = [[NSString alloc] initWithData:thisResponseData 
												   encoding:NSASCIIStringEncoding];
	
    SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	
    if ([[responseAsDictionary objectForKey:@"restaurants"] count] != 0) {
        NSArray *restaurantArray = [responseAsDictionary objectForKey:@"restaurants"];
        NSDictionary *thisRestaurant = [restaurantArray objectAtIndex:0];     
        self.urlImageArray = [thisRestaurant objectForKey:@"photoURL"];
    }
    
    [super connectionDidFinishLoading:theConnection];
}

-(void)showPhotoViewer {
    [Logger logEvent:kEventRDTapPhoto];
    NSLog(@"show photo viewer");
    if ([self.urlImageArray count]) {
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        for (NSString *url in self.urlImageArray) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
        }
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];
        //[browser setInitialPageIndex:0]; // Can be changed if desired
        [self.navigationController pushViewController:browser animated:YES];
        [browser release];
        [photos release];
        
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DLog(@"section is %@", section);
    id <NSFetchedResultsSectionInfo> sectionInfo = 
	[[self.fetchedResultsController sections] 
	 objectAtIndex:section];
	if (sectionInfo == nil){
		return 0;
	}
	//Add 1 for the "Add a new dish cell"
	return [sectionInfo numberOfObjects];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self pushDishViewController:[self.fetchedResultsController 
								  objectAtIndexPath:[NSIndexPath 
													 indexPathForRow:indexPath.row 
													 inSection:indexPath.section]]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return self.menuSectionHeaderView;
}

#pragma mark -
#pragma mark action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
        //cancelled
        return;
    }
	
	DLog(@"show the picture thing");
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	[imagePicker setAllowsEditing:YES];
	
	if(buttonIndex == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		//then push the imagepicker
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
		[imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
	}
	else {
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	[self presentModalViewController:imagePicker animated:YES]; 
}

#pragma mark -
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//self.dishImageFromPicker = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
		self.newPicture = [info objectForKey:@"UIImagePickerControllerEditedImage"];

        [self.navigationController setNavigationBarHidden: YES animated:YES];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.view.userInteractionEnabled = NO;
        
		self.hud.labelText = @"Uploading photo...";
		self.hud.delegate = self;
		self.hud.mode = MBProgressHUDModeIndeterminate;
		
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
		ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [[self.restaurant restaurant_id] intValue]] forKey:@"restaurantId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		DLog(@"done calling add photo, time to call rateDish");
	}
	[self dismissModalViewControllerAnimated:YES];
}
-(void)hudWasHidden {
    [self.navigationController setNavigationBarHidden: NO animated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	DLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
	//[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark AddADishProtocolDelegate method
-(void)addDishDone {
    //Must refresh from network
    [Logger logEvent:kEventRDDoneAddingDish];
	[self.navigationController popViewControllerAnimated:YES];
    [self updateFetch];
}
#pragma mark -
#pragma mark network
- (void)requestFailed:(ASIHTTPRequest *)request {
	self.hud.labelText = @"Oops, error with the network. Try again later.";
	[self.hud hide:YES afterDelay:3];
	self.view.userInteractionEnabled = YES;
   // if ([error isKindOfClass:[ASIRequestTimedOutError class]]) {
		NSLog(@"request failed");
	//}
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	DLog(@"response string for any of these calls %@", responseString);
	DLog(@"the request was %@", request);
	if ([[[request.url pathComponents] objectAtIndex:[[request.url pathComponents] count] - 1] isEqualToString:@"flagRestaurant"] ) {
		NSLog(@"this is a flag restaurant call, do something different");
		UIAlertView *a;
		NSString *message;
		if (request.responseStatusCode == 200)
			message = @"Your request flag this restaurant was successful. Thanks for making TopDish great!";
		else  {
			message = @"Your request to flag this Restaurant Failed. Please try later";	
			self.flagView.hidden = NO;
		}
		
		a = [[UIAlertView alloc] initWithTitle:@"Feedback" 
									   message:message
									  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[a show];
		[a release];
		return;
	}
	
	//Send feedback if broken
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		return;
	}
	
	NSError *error;
	SBJSON *parser = [SBJSON new];
	NSDictionary *responseAsDict = [parser objectWithString:responseString error:&error];	
	[parser release];
	
	DLog(@"the dictionary should be a %@", responseAsDict);
	
	ASIFormDataRequest *newRequest;
	
	if ([[responseAsDict objectForKey:@"rc"] intValue]) {
		UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Request Failed" 
															message:[responseAsDict objectForKey:@"message"]
														   delegate:self 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertview show];
		[alertview release];
		return;
	}
	if ([responseAsDict objectForKey:@"url"]) {
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", [responseAsDict objectForKey:@"url"]]];
		DLog(@"the url for sending the photo is %@", url);
		
        if(self.newPicture.size.width > DEFAULTIMAGEDIMENSION || self.newPicture.size.height > DEFAULTIMAGEDIMENSION)
            self.newPicture = [self.newPicture resizedImage:CGSizeMake(384, 384) interpolationQuality:kCGInterpolationHigh];

		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setData:UIImagePNGRepresentation(self.newPicture) forKey:@"photo"];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [[self.restaurant restaurant_id] intValue]] forKey:@"restaurantId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		return;
		
	}
	self.hud.labelText = @"Successfully submitted the image";
	[self.hud hide:NO afterDelay:3];
	self.view.userInteractionEnabled = YES;
    [self reloadView];
	
	DLog(@"done!");
}


#pragma mark -
#pragma mark actions 
-(IBAction)flagThisRestaurant{
    [Logger logEvent:kEventRDFlagRestaurant];
	DLog(@"flagging this restaurant");
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/flagRestaurant"]];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[self.restaurant restaurant_id] forKey:@"restaurantId"];
	[request setPostValue:@"0" forKey:@"type"];
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	
	[request setDelegate:self];
	[request startAsynchronous];
	
	self.flagView.hidden = YES;
}

-(IBAction) pushAddDishViewController {
    [Logger logEvent:kEventRDAddDishTapped];
	if ([[AppModel instance] isLoggedIn]) {
		AddADishViewController *addDishViewController = [[AddADishViewController alloc] initWithNibName:@"AddADishViewController" bundle:nil];
		addDishViewController.title = @"Add a Dish";
		addDishViewController.delegate = self;
		addDishViewController.restaurant = restaurant;
		[self.navigationController pushViewController:addDishViewController animated:YES];
		[addDishViewController release];
	}
	else {
		NSLog(@"show the modal login thing");
		mPostLoginAction = @selector(pushAddDishViewController);
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] animated:YES];
	}

}

-(IBAction)callRestaurant{
	[Logger logEvent:kEventRDCallRestaurant];
	NSString *phoneNumber = [NSString stringWithFormat:@"tel:%@", [restaurant phone]];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
	phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSURL *url = [NSURL URLWithString:phoneNumber];
	
	[ [UIApplication sharedApplication] openURL:url];
	
}
-(void)startPictureFlow {
	if ([[AppModel instance] isLoggedIn]) {
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil//@"Camera or Library?" 
																 delegate:self 
														cancelButtonTitle:nil 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil];
		[actionSheet addButtonWithTitle:@"Take a picture"];
		[actionSheet addButtonWithTitle:@"Choose from Library"];
		actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
		[actionSheet showInView:self.navigationController.tabBarController.view];	
		[actionSheet release];
	}
	else {
		mPostLoginAction = @selector(startPictureFlow);
		[self presentModalViewController:[LoginModalView viewControllerWithDelegate:self] 
								animated:YES];
	}

}
-(void)takePicture:(UITapGestureRecognizer *)sender {
    NSLog(@"sender is %@", sender);
    if ([sender state] == UIGestureRecognizerStateEnded) {
        [Logger logEvent:kEventRDTakePicture];
        [self startPictureFlow];
    }
	}
-(void)tapEmptyPhoto:(UITapGestureRecognizer *)sender {
    [Logger logEvent:kEventRDTapEmptyPhoto];
    [self startPictureFlow];

}
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.5];

	if (!mMapShowing)
		[self.mapOverlay setFrame:CGRectOffset([self.mapOverlay frame], 
											   0, 
											   (self.mapOverlay.frame.size.height - 20))]; // Move imageView off screen
	else
		[self.mapOverlay setFrame:CGRectOffset([self.mapOverlay frame], 
											   0, 
											   -(self.mapOverlay.frame.size.height - 20))]; // Move imageView off screen

	[UIView commitAnimations]; // End animations

	mMapShowing = !mMapShowing;
    //CGPoint translate = [sender translationInView:self.mapOverlay];
//    CGRect newFrame = self.mapOverlay.frame;
//	CGRect anotherFrame = self.mapOverlay.frame;
//	DLog(@"the translate is %f, the origin is %f", translate, newFrame.origin.y);
//	DLog(@"another frame %f", anotherFrame.origin.y);
//	//if (newFrame.origin.y >= 0)
//	newFrame.origin.y = translate.y;
//	
//	//else 
////		newFrame.origin.y = 0;
//	//sender.view.frame = newFrame;
//
//     //if (sender.state == UIGestureRecognizerStateEnded)
//		self.mapOverlay.frame = newFrame;
}

#pragma mark -
#pragma mark map stuff
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	if([annotation isKindOfClass:[RestaurantAnnotation class]]){
		static NSString *RestaurantAnnotationIdentifier = @"RestaurantMapAnnotationIdentifier";
		
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
		[self.mapView dequeueReusableAnnotationViewWithIdentifier:RestaurantAnnotationIdentifier];
		
		if(!annotationView){
			annotationView = [[[MKPinAnnotationView alloc]
							   initWithAnnotation:annotation  
							   reuseIdentifier:RestaurantAnnotationIdentifier] autorelease];
			annotationView.canShowCallout = YES;
		}
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		annotation = (RestaurantAnnotation *)annotation;
		//rightButton.tag = [[[(RestaurantAnnotation*)annotation thisRestaurant] dish_id] intValue];
		annotationView.rightCalloutAccessoryView = rightButton;
		
		return annotationView;
	}
	DLog(@"returned nil? hmmm");
	return nil;
}

#pragma mark -
#pragma mark LoginModalViewDelegate
-(void)loginFailed {
	NSLog(@"login failed");
}

-(void)loginStarted {
	NSLog(@"login started");
}

-(void)loginComplete {
	DLog(@"the login is fully completed");
	[self dismissModalViewControllerAnimated:YES];
    if (mPostLoginAction)
        [self performSelector:mPostLoginAction];
}

-(void)noLoginNow {
	NSLog(@"not now pressed");
	[self dismissModalViewControllerAnimated:YES];
}

-(void)facebookLoginComplete {
	
}

#pragma mark -
#pragma mark IncomingProcessorDelegate
-(void)saveDishesComplete:(NSArray *)newDishes {
    NSLog(@"save dishes complete in restaurant detail view");
	[self.tableView performSelectorOnMainThread:@selector(reloadData) 
									 withObject:self 
								  waitUntilDone:NO];
}
-(void)saveRestaurantsComplete {
    NSLog(@"save restaurant complete in restaurant detail view");

	[self.tableView performSelectorOnMainThread:@selector(reloadData) 
									 withObject:self 
								  waitUntilDone:NO];
}

#pragma mark -
#pragma mark Memory management


- (void)dealloc {
    self.cameraImage = nil;
	self.restaurant = nil;
	self.restaurantHeader = nil;
	self.restaurantName = nil;
	self.restaurantAddress = nil;
	self.restaurantPhone = nil;
	self.restaurantImage = nil;
	
	self.newPicture = nil;
	
	self.mapRow = nil;
	self.mapView.delegate = nil;
	self.mapView = nil;
	self.flagView = nil;
	
	self.menuSectionHeaderView = nil;
	self.hud = nil;
    [super dealloc];
}


@end

