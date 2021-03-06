//
//  TopDishAppDelegate.m
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TopDishAppDelegate.h"
#import "IPadDishTableViewController.h"
#import "IPadOpeningViewController.h"

#import "JSON.h"
#import "Dish.h"
#import "ASIFormDataRequest.h"
#import "constants.h"
#import "AppModel.h"
#import "RestaurantList.h"
#import "FeedbackStringProcessor.h"

@implementation TopDishAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;
@synthesize segmentsController = mSegmentsController;
@synthesize segmentedControl = mSegmentedControl;
@synthesize splitViewController  = mSplitViewController;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
}

- (void)switchViewControllers {
	DLog(@"switch view controllers");
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    	
    
    //MixPanel setup
    mixpanel = [MixpanelAPI sharedAPIWithToken:MIXPANEL_TOKEN];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/mobileInit", NETWORKHOST]];	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	//seems like i have to supply an empty post in order to make this a post not a get....boo
	[request setPostValue:nil forKey:@"comment"];

	// Upload an NSData instance
	[request setDelegate:self];
	[request startAsynchronous];
	
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
        
        NSArray * navsviewControllers = self.navigationController.viewControllers;
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:navsviewControllers];
        
        RestaurantList *restaurantList = [[RestaurantList alloc] initWithNibName:@"RestaurantList" bundle:nil];
        [viewControllers addObject:restaurantList];
        [restaurantList release];
        
        self.segmentsController = [[SegmentsController alloc] initWithNavigationController:self.navigationController viewControllers:viewControllers];
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[viewControllers arrayByPerformingSelector:@selector(title)]];
        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        
        [self.segmentedControl addTarget:self.segmentsController
                                  action:@selector(indexDidChangeForSegmentedControl:)
                        forControlEvents:UIControlEventValueChanged];
        
        self.segmentedControl.selectedSegmentIndex = 0;
        [self.segmentsController indexDidChangeForSegmentedControl:self.segmentedControl];
        [window addSubview:tabBarController.view];
        [window makeKeyAndVisible];
        
	}
    else {
        //This is an iPad
        self.splitViewController = [[UISplitViewController alloc] init];
        
        IPadDishTableViewController *root = [[[IPadDishTableViewController alloc] init] autorelease];
        IPadOpeningViewController *detail = [[[IPadOpeningViewController alloc] init] autorelease]; 
        
        UINavigationController *rootNav = [[[UINavigationController alloc] initWithRootViewController:root]autorelease];
        
        UINavigationController *detailNav = [[[UINavigationController alloc] initWithRootViewController:detail] autorelease];
        
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:rootNav, detailNav, nil];
        self.splitViewController.delegate = detail;
        
        
        [window addSubview:self.splitViewController.view];
        
        [window makeKeyAndVisible];        
    }
    
	
	[[AppModel instance] facebook];
	
    return YES;
}

-(NSString *)getValue:(NSString *)value fromString:(NSString *)source {
	NSRange range = [source rangeOfString:value];
	int startOfDestination = range.length + range.location;
	NSRange valueRange;
	valueRange.location = startOfDestination + 1;
	valueRange.length = [source length] - startOfDestination-1;
	
	return [source substringWithRange:valueRange];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	if ([[url host] hasPrefix:@"googleAuthResponse"]) {
		NSString *apiKey = [self getValue:@"apiKey" fromString:[url absoluteString]];
		[[[AppModel instance] user] setObject:apiKey forKey:keyforauthorizing];
		[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneLogin object:nil];
		
		return TRUE;
	}

	return [[[AppModel instance] facebook] handleOpenURL:url];
}

NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [[num1 objectForKey:@"order"] intValue];
    int v2 = [[num2 objectForKey:@"order"] intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	if (request.responseStatusCode != 200 && ![[request.url absoluteString] hasPrefix:@"sendUserFeedback"]) {
		NSString *message = [FeedbackStringProcessor buildStringFromRequest:request];
		[FeedbackStringProcessor SendFeedback:message delegate:nil];
		return;
	}
	// Use when fetching binary data
	NSString *responseText = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[parser release];
		[responseText release];
		return;
	}
	
	NSArray *responseAsArray = [responseAsDictionary objectForKey:@"tags"];
	NSDictionary *defaultObject = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0", @"", @"None", @"0", nil]
															  forKeys:[NSArray arrayWithObjects:@"id", @"name", @"type", @"order", nil]];
	NSMutableArray *priceTypeTags = [NSMutableArray arrayWithObject:defaultObject];
	NSMutableArray *mealTypeTags = [NSMutableArray arrayWithObject:defaultObject];
	NSMutableArray *allergenTypeTags = [NSMutableArray arrayWithObject:defaultObject];
	NSMutableArray *lifestyleTypeTags = [NSMutableArray arrayWithObject:defaultObject];
	NSMutableArray *cuisineTypeTags = [NSMutableArray arrayWithObject:defaultObject];
	for (NSDictionary *d in responseAsArray)
	{
		if ([[d objectForKey:@"type"] isEqualToString:kMealTypeString])
			[mealTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kPriceTypeString])
			[priceTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kAllergenTypeString])
			[allergenTypeTags addObject:d];
		
		if ([[d objectForKey:@"type"] isEqualToString:kLifestyleTypeString])
			[lifestyleTypeTags addObject:d];		
		
		if ([[d objectForKey:@"type"] isEqualToString:kCuisineTypeString])
			[cuisineTypeTags addObject:d];
		
	}
	NSArray *sortedArray; 
	sortedArray = [priceTypeTags sortedArrayUsingFunction:intSort context:NULL];

	[parser release];
	[responseText release];

	[[AppModel instance] setPriceTags:sortedArray];
	[[AppModel instance] setMealTypeTags:mealTypeTags];
	[[AppModel instance] setAllergenTags:allergenTypeTags];
	[[AppModel instance] setLifestyleTags:lifestyleTypeTags];
	[[AppModel instance] setCuisineTypeTags:cuisineTypeTags];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
		[managedObjectContext_ setMergePolicy: NSMergeByPropertyStoreTrumpMergePolicy];// NSOverwriteMergePolicy];
	}
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TopDish" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"TopDish.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

