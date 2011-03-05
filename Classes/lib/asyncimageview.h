//
//  AsyncImageView.h
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//  http://www.markj.net/iphone-asynchronous-table-image/
//

#import <UIKit/UIKit.h>
#import "ObjectWithImage.h"

@interface AsyncImageView : UIView {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to 
	// to build into this class?

	ObjectWithImage *owningObject;
	Boolean showThisIndicator;
	UIActivityIndicatorView *spinner;
	UIImageView *thisImageView; 
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
	Boolean isThumb;
@private
    NSManagedObjectContext *managedObjectContext_;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)loadImageFromURL:(NSURL*)url withImageView:(UIImageView *)imageView isThumb:(Boolean)isThumb showActivityIndicator:(Boolean)showIndicator;
- (UIImage*) image;
@property (nonatomic, retain) ObjectWithImage *owningObject;
@property (nonatomic, assign) Boolean isThumb;
@end
