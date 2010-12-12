//
//  TopDishAppDelegate.m
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TopDishAppDelegate.h"
#import "DishTableViewController.h"
#import "JSON.h"
#import "Dish.h"


@implementation TopDishAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
    
    DishTableViewController *dishTableViewController = (DishTableViewController *)[navigationController topViewController];
    dishTableViewController.managedObjectContext = self.managedObjectContext;
	
}

- (void)switchViewControllers {
	NSLog(@"switch view controllers");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    //[window addSubview:navigationController.view];
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

	//[self initializedatabase];
    return YES;
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}

//-(void)initializedatabase {
//	NSLog(@"initialize database");
//	
//	NSString *restoJsonData = @"[\
//							   {\
//								   \"id\":138,\
//								   \"restaurantName\":\"The Burger Joint\",\
//								   \"addressLine1\":\"123 main street\",\
//								   \"addressLine2\":\"\",\
//								   \"city\":34,\
//								   \"state\":12,\
//								   \"neighborhood\":\"pac Heights\"\
//								   },\
//								   [\
//								   {\
//								   \"id\":138,\
//								   \"restaurantName\":\"The Burger Joint\",\
//								   \"addressline1\":\"123 main street\",\
//								   \"addressLine2\":\"\",\
//								   \"city\":\"San Francisco\",\
//								   \"state\":\"CA\",\
//								   \"neighborhood\":\"Nob Hill\"\
//								   }}";
//	NSString *jsonData = @"[\
//	{\
//	\"id\":38,\
//	\"name\":\"Bacon Burger\",\
//	\"description\":\"7 lbs of raw beef, covered in a package of bacon. Seriously, the bacon isn't even unwrapped. There's even a pricetag on some of them. Get it while it's raw.\",\
//	\"restaurantID\":37,\
//	\"restaurantName\":\"The Burger Joint\",\
//	\"latitude\":37.33215,\
//	\"longitude\":-122.02935,\
//	\"posReviews\":34,\
//	\"negReviews\":12,\
//	\"photoURL\":\"http://topdish1.appspot.com/getPhoto?id=84001\"\
//	},\
//	{\
//	\"id\":139,\
//	\"name\":\"Carne Asada Tacos\",\
//	\"description\":\"Like Meat? Try these Carne Asada Tacos. Rumor has it that there is actual human meat in there to add some 'urban' flavor.\",\
//	\"restaurantID\":63,\
//	\"restaurantName\":\"The Fry Shop\",\
//	\"latitude\":37.33216,\
//	\"longitude\":-122.02999,\
//	\"posReviews\":92,\
//	\"negReviews\":21,\
//	\"photoURL\":\"http://topdish1.appspot.com/getPhoto?id=74001\"\
//	},\
//	{\
//	\"id\":1,\
//	\"name\":\"Tuna Tartar\",\
//	\"description\":\"Tartare is a preparation of finely chopped raw meat or fish optionally with seasonings and sauces. Usually Raw fish is gross, but in the case of Tartar, you can sense the dilecitble dilectability of such a devine dish. One time this guy ate it and then he died.\",\
//	\"restaurantID\":63,\
//	\"restaurantName\":\"Salad Fingers\",\
//	\"latitude\":37.33225,\
//	\"longitude\":-122.02975,\
//	\"posReviews\":12,\
//	\"negReviews\":5,\
//	\"photoURL\":\"http://topdish1.appspot.com/getPhoto?id=70001\"\
//	},\
//	{\
//	\"id\":139,\
//	\"name\":\"Miso Soup\",\
//	\"description\":\"Miso....A Type of Japanese Soup. Excellent. Your wager? Horney. Miso Horney. Great.\",\
//	\"restaurantID\":63,\
//	\"restaurantName\":\"The Fry Shop\",\
//	\"latitude\":37.33235,\
//	\"longitude\":-122.02965,\
//	\"posReviews\":89,\
//	\"negReviews\":32,\
//	\"photoURL\":\"http://topdish1.appspot.com/getPhoto?id=72001\"\
//	},\
//	{\
//	\"id\":139,\
//	\"name\":\"Sloppy Joe\",\
//	\"description\":\"Everyone loves a sloppy one\",\
//	\"restaurantID\":63,\
//	\"restaurantName\":\"Busters\",\
//	\"latitude\":37.3295,\
//	\"longitude\":-122.02975,\
//	\"posReviews\":19,\
//	\"negReviews\":11,\
//	\"photoURL\":\"http://topdish1.appspot.com/getPhoto?id=70002\"\
//	}\
//	]";
//	SBJSON *parser = [SBJSON new];
//	NSArray *responseAsArray = [parser objectWithString:jsonData error:NULL];
//	[parser release];
//	
//	for (int i =0; i < [responseAsArray count]; i++){
//		Dish *thisDish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" inManagedObjectContext:self.managedObjectContext];
//		NSDictionary *thisElement = [responseAsArray objectAtIndex:i];
//		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
//		[thisDish setDish_name:[thisElement objectForKey:@"name"]];
//		[thisDish setDish_description:[thisElement objectForKey:@"description"]];
//		[thisDish setDish_photoURL:[thisElement objectForKey:@"photoURL"]];
//		[thisDish setLatitude:[thisElement objectForKey:@"latitude"]];
//		[thisDish setLongitude:[thisElement objectForKey:@"longitude"]];
//		[thisDish setPosReviews:[thisElement objectForKey:@"posReviews"]];
//		[thisDish setNegReviews:[thisElement objectForKey:@"negReviews"]];
//		[thisDish setDish_id:[thisElement objectForKey:@"id"]];
//		NSLog(@"adding all the stuff to a dish: %@", [thisDish price]);
//	}
//	
//	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Dish"  
//											  inManagedObjectContext:self.managedObjectContext];
//	[fetchRequest setEntity:entity];
//	
////	NSError *error;
//	//NSArray *items = [self.managedObjectContext
////					  executeFetchRequest:fetchRequest error:&error];
////	
//	[fetchRequest release];	
//}

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

