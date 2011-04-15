//
//  DishDetailViewController.m
//  TopDish
//
//  Created by roderic campbell on 1/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DishDetailViewController.h"
#import "asyncimageview.h"
#import "constants.h"
#import "JSON.h"
#import "RestaurantDetailViewController.h"
#import "ASIFormDataRequest.h"
#import "AppModel.h"

#define kImageSection 0
#define kDescriptionSection 1
#define kCommentsSection 2

#define kCommentHeight 14

#define kMoreDishesAtString @"More Dishes At"
@implementation DishDetailViewController

@synthesize thisDish = mThisDish;
@synthesize dishImageCell = mDishImageCell;
@synthesize dishImageView = mDishImageView;
@synthesize dishDescriptionCell = mDishDescriptionCell;
@synthesize dishDescriptionLabel = mDishDescriptionLabel;

@synthesize dishTagsLabel = mDishTagsLabel;

@synthesize negativeReviews = mNegativeReviews;
@synthesize positiveReviews = mPositiveReviews;

@synthesize dishNameLabel = mDishNameLabel;
@synthesize restaurantNameLabel = mRestaurantNameLabel;

@synthesize reviews = mReviews;
@synthesize responseData = mResponseData;
@synthesize managedObjectContext;

@synthesize tvCell = mTvCell;
@synthesize moreButton = mMoreButton;
@synthesize newPicture = mNewPicture;

@synthesize tableView = mTableView;

@synthesize interactionOverlay = mInteractionOverlay;


-(void)refreshFromNetwork {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/dishDetail?id[]=%@", 
									   NETWORKHOST, 
									   [self.thisDish dish_id]]];
	//Start up the networking
	DLog(@"the comments url is %@", url);
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE]; 
	[conn release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == kDescriptionSection)
		return @"Description";
	if (section == kCommentsSection)
		return @"Comments";
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case kImageSection:
			return 1;
			break;
		case kDescriptionSection:
			return 1;
			break;
		
		case kCommentsSection:
			return [self.reviews count];
		default:
			return 1;
			break;
	}
    return 0;
}
- (UITableViewCell *)commentsCellForIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"CommentsCellIdentifier";
	NSString *comment = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"comment"];
	NSString *creator = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"creator"];
	NSNumber *voteDirection = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"direction"];
	
	UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		//CommentCell comes from the file name CommentsCell.xib
		[[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
		cell = mTvCell;
		self.tvCell = nil;
	}
	
	UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = comment;
	
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"-%@",creator];
	DLog(@"the number of rows is %d", label.numberOfLines);
	
	UIImageView *voteDirectionImage = (UIImageView *)[cell viewWithTag:3];
	if ([voteDirection intValue] == 1) {
		voteDirectionImage.image = [UIImage imageNamed:@"thumbsup.jpg"];
		NSLog(@"thumbs up");
	}
	else {
		voteDirectionImage.image = [UIImage imageNamed:@"thumbsdown.jpg"];
		NSLog(@"thumbs down");
	}
	
	return (UITableViewCell *)cell;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

	switch (indexPath.section) {
		case kImageSection:
			cell = self.dishImageCell;
			break;
			
		case kDescriptionSection:
			cell = self.dishDescriptionCell;
			break;

		case kCommentsSection:
			return [self commentsCellForIndexPath:indexPath];

		default:
			break;
	}
	// Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kImageSection) {
		//return 280;
		return self.dishImageCell.bounds.size.height;
	}
	if (indexPath.section == kDescriptionSection) {
		
		//self.dishDescriptionCell.frame = CGRectMake(c.origin.x, c.origin.y, c.size.width, c.size.height);
		//self.dishDescriptionCell.frame.size.height = [self.dishDescriptionLabel numberOfLines] * 25;
		return self.dishDescriptionCell.bounds.size.height;
	}
//	if (indexPath.section == kCommentsSection) {
//		NSString *s = [[self.reviews objectAtIndex:indexPath.row] objectForKey:@"comment"];
//		UIFont *f = [UIFont fontWithName:@"Helvetica" size:14];
//		CGSize expectedLabelSize = [s sizeWithFont:f forWidth:100 lineBreakMode:UILineBreakModeWordWrap];
//		DLog(@"the size of %@ is %f %f", s, expectedLabelSize.height, expectedLabelSize.width);
//	}
	
	
	return 100;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidLoad {
		
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:self.interactionOverlay.frame] autorelease];
	
	DLog(@"view did load for %@", [self.thisDish objName]);
	if( [[self.thisDish photoURL] length] > 0 ){
		NSRange aRange = [[self.thisDish photoURL] rangeOfString:@"http://"];
		NSString *prefix = @"";
		if (aRange.location ==NSNotFound)
			prefix = NETWORKHOST;
		//TODO we are not getting height and width
		NSString *urlString = [NSString stringWithFormat:@"%@%@", 
							   prefix,
							   [self.thisDish photoURL], 
							   self.dishImageView.bounds.size.width, 
							   self.dishImageView.bounds.size.height]; 

		NSURL *photoUrl = [NSURL URLWithString:urlString];
		AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:[self.dishImageView frame]] autorelease];
		[asyncImage setOwningObject:self.thisDish];
		[asyncImage loadImageFromURL:photoUrl withImageView:self.dishImageView 
							 isThumb:NO showActivityIndicator:FALSE];
	}
	[self.dishDescriptionLabel setText:[self.thisDish dish_description]];
	[self.dishDescriptionLabel numberOfLines];
	
	AppModel *app = [AppModel instance];
	Dish *d = self.thisDish;
	NSString *tagString = [NSString stringWithFormat:@"%@, %@, %@, %@",
						   [app tagNameForTagId:d.cuisineType],
						   [app tagNameForTagId:d.mealType],
						   [app tagNameForTagId:d.price],
						   [app tagNameForTagId:d.lifestyleType] ? [app tagNameForTagId:d.lifestyleType]:@""];
	self.dishTagsLabel.text = tagString;
	
	[self.dishNameLabel setText:[self.thisDish objName]];
	[self.dishNameLabel setTextColor:kTopDishBlue];
	
	[self.restaurantNameLabel setText:[[self.thisDish restaurant] objName]];
	[self.restaurantNameLabel setTextColor:kTopDishBlue];
	
	UITapGestureRecognizer *restaurantTouchGesture = [[UITapGestureRecognizer alloc]
													  initWithTarget:self action:@selector(pushRestaurantDetailController)];
    [self.restaurantNameLabel addGestureRecognizer:restaurantTouchGesture];
    [restaurantTouchGesture release];
	
	
	NSString *buttonTitle = @"More Dishes Here";
	
	[self.moreButton setTitle:buttonTitle
					 forState:UIControlStateNormal];

	[self refreshFromNetwork];
	
		
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",[self.thisDish negReviews]];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",[self.thisDish posReviews]];	
}

-(void)viewDidAppear:(BOOL)animated {
	
	[UIView beginAnimations:@"animateOverlay" context:NULL]; // Begin animation
	[self.interactionOverlay setFrame:CGRectOffset([self.interactionOverlay frame], 
												   0, 
												   -self.interactionOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	
}
-(void)viewWillDisappear:(BOOL)animated {
	[UIView beginAnimations:@"animateOverlay" context:NULL]; // Begin animation
	[self.interactionOverlay setFrame:CGRectOffset([self.interactionOverlay frame], 
												   0, 
												   self.interactionOverlay.frame.size.height)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	self.thisDish = nil;
	self.dishImageCell = nil;
	self.dishImageView = nil;
	self.negativeReviews = nil;
	self.positiveReviews = nil;
	
	self.dishDescriptionCell = nil;
	self.dishDescriptionLabel = nil;
	
	self.dishNameLabel = nil;
	self.restaurantNameLabel = nil;
	
	self.reviews = nil;
	self.responseData = nil;
	
	//TODO - in general, I need to get the moc from the app model
	self.managedObjectContext = nil;
	self.tvCell = nil;
	self.moreButton = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Network Delegate 

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	DLog(@"didFinishLoading dishDetailViewController start");
	NSString *responseText = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
	
	SBJSON *parser = [SBJSON new];
	NSError *error;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	DLog(@"responseAsDictionary %@", responseAsDictionary);		
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[responseText release];
		[parser release];
		return;
	}
	
	NSArray *responseAsArray = [responseAsDictionary objectForKey:@"dishes"];
	NSDictionary *thisDishDetailDictionary = [responseAsArray objectAtIndex:0];
	//DLog(@"%@", thisDishDetailDictionary);
	[parser release];
	if(self.reviews == nil){
		self.reviews = [NSArray alloc];
	}
	
	self.reviews = [[thisDishDetailDictionary objectForKey:@"reviews"] copy];
	
	self.thisDish.posReviews = [thisDishDetailDictionary objectForKey:@"posReviews"];
	self.thisDish.negReviews = [thisDishDetailDictionary objectForKey:@"negReviews"];
	
	self.negativeReviews.text = [NSString stringWithFormat:@"-%@",self.thisDish.negReviews];
	self.positiveReviews.text = [NSString stringWithFormat:@"+%@",self.thisDish.posReviews];

	[responseText release];
	self.responseData = nil;
	[self.tableView reloadData];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	DLog(@"didFinishLoading dishDetailViewController end");

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	DLog(@"This is the dish detail error %@", error);
	
	//TODO when the server is in a bit better shape I'll have to 
	//remove this default call as well as the hard coded data
	//[self connectionDidFinishLoading:connection];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" message:@"There was a network issue. Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
	[alert show];
	[alert release];	
#endif
	self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(self.responseData == nil){
		self.responseData = data;
		//self.responseText = [[NSData alloc] initWithData:data];
	}
	else {
		DLog(@"a ha!, the response text was not null, which means we may be missing some data");
	}

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	DLog(@"error %@", [request error]);
}

#pragma mark -
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	//self.dishImageFromPicker = [info objectForKey:@"UIImagePickerControllerEditedImage"];
	if ([info objectForKey:@"UIImagePickerControllerEditedImage"]) {
		self.newPicture = [info objectForKey:@"UIImagePickerControllerEditedImage"];
		
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/addPhoto"]];
		ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [[self.thisDish dish_id] intValue]] forKey:@"dishId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		DLog(@"done calling add photo, time to call rateDish");
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	DLog(@"response string for any of these calls %@", responseString);
	
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
		
		newRequest = [ASIFormDataRequest requestWithURL:url];
		[newRequest setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
		[newRequest setData:UIImagePNGRepresentation(self.newPicture) forKey:@"photo"];
		[newRequest setPostValue:[NSString stringWithFormat:@"%d", [[self.thisDish dish_id] intValue]] forKey:@"dishId"];
		[newRequest setDelegate:self];
		[newRequest startAsynchronous];
		return;
		
	}
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Upload Success"
														message:@"Successfully submitted the image" 
													   delegate:nil
											  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	DLog(@"done!");
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	DLog(@"cancelled, should we go back another level?");
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheet
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
		
		[imagePicker setCameraOverlayView:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
	}
	else {
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	[self presentModalViewController:imagePicker animated:YES]; 
}

#pragma mark -
#pragma mark IBActions
-(IBAction)takePicture
{
	if ([[[AppModel instance] user] objectForKey:keyforauthorizing] ) {
		
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
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not logged in"
															message:@"Must log into submit an image" 
														   delegate:nil
												  cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}

}

-(IBAction)pushRateDishController {
	//RateADishViewController *rateDish = [[RateADishViewController alloc] init];
	RateADishViewController *rateDish = 
	[[RateADishViewController alloc] initWithNibName:@"RateADishViewController" 
											  bundle:nil];
	[rateDish setThisDish:self.thisDish];
	[rateDish setDelegate:self];
	[self.navigationController pushViewController:rateDish 
										 animated:YES];
	
	[rateDish release];
	
}

-(void)pushRestaurantDetailController {
	RestaurantDetailViewController *restaurantController = 
	[[RestaurantDetailViewController alloc] initWithNibName:@"RestaurantDetailView" 
													 bundle:nil];
	[restaurantController setManagedObjectContext:self.managedObjectContext];

	[restaurantController setRestaurant:[self.thisDish restaurant]];
	[self.navigationController pushViewController:restaurantController animated:YES];
	[restaurantController release];
}

-(IBAction)tapRestaurantButton {
	[self pushRestaurantDetailController];
}

-(IBAction)flagThisDish{
	DLog(@"flagging this dish");
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@", NETWORKHOST, @"api/flagDish"]];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[self.thisDish dish_id] forKey:@"dishId"];
	[request setPostValue:[[[AppModel instance] user] objectForKey:keyforauthorizing] forKey:keyforauthorizing];
	
	[request setDelegate:self];
	[request startAsynchronous];
}

-(void)doneRatingDish {
	[self refreshFromNetwork];
	[self.navigationController popViewControllerAnimated:YES];
}
@end

