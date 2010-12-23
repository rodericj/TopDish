//
//  AsyncImageView.m
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import "AsyncImageView.h"


// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn't block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time. 

@implementation AsyncImageView
@synthesize owningObject;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize isThumb;
- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	[connection release];
	[data release]; 
    [super dealloc];
}


- (void)loadImageFromURL:(NSURL*)url withImageView:(UIImageView *)imageView isThumb:(Boolean)isThumbNail showActivityIndicator:(Boolean)showIndicator {
	if (connection!=nil) { [connection release]; } //in case we are downloading a 2nd image
	if (data!=nil) { [data release]; }
	isThumb = isThumbNail;
	thisImageView = imageView;
	[thisImageView retain];
	showThisIndicator = showIndicator;
	if(showThisIndicator){
		//Add a spinner
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
												UIActivityIndicatorViewStyleWhiteLarge];
		[spinner setFrame:[imageView frame]];
		[spinner startAnimating];
		[thisImageView addSubview:spinner];
	}

	NSURLRequest* request;
	if ([owningObject imageData] && !isThumb){
		thisImageView.image = [UIImage imageWithData:[owningObject imageData]];
	}
	else if ([owningObject ImageDataThumb] && isThumb){
		thisImageView.image = [UIImage imageWithData:[owningObject ImageDataThumb]];
	}
	else if(([owningObject imageData] == NULL && !isThumb) || ([owningObject ImageDataThumb] == NULL && isThumb)){
		request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:8];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
	else {
		NSAssert(1, @"Should have covered all of the cases at this point");
	}

	
	
	//if([owningObject imageData] && !(isThumb && [[owningObject imageData] length] < 10000000)){
//		thisImageView.image = [UIImage imageWithData:[owningObject imageData]];
//	}
//	else{
//		request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:8];
//		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 	
//	}
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
#ifndef AirplaneMode
	NSLog(@"%@", error);
#endif
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { 
		data = [[NSMutableData alloc] initWithCapacity:2048]; 
	} 
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image 
	[connection release];
	connection=nil;
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	if (showThisIndicator) {
		//stop spinner
		[spinner stopAnimating];
	}
	//make an image view for the image
	//UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
	if(thisImageView.image == NULL){
		NSLog(@"ok, the image view's image is nil");
	}

	thisImageView.image = [UIImage imageWithData:data];
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	//imageView.contentMode = UIViewContentModeScaleAspectFit;
//	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
//	[self addSubview:imageView];
//	imageView.frame = self.bounds;
//	[imageView setNeedsLayout];
//	[self setNeedsLayout];
	
	if (owningObject) {
		if(isThumb){
			[owningObject setImageDataThumb:data];
		}
		else{
			[owningObject setImageData:data];
		}
		NSError *error;

		if([self.managedObjectContext save:&error]){
			NSLog(@"error saving: %@",error);
		}
	}
	[data release]; //don't need this any more, its in the UIImageView now
	data=nil;
}

//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

@end
