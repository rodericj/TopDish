//
//  TopDishAppDelegate.h
//  TopDish
//
//  Created by Roderic Campbell on 10/3/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SegmentsController.h"

@interface TopDishAppDelegate : NSObject <UIApplicationDelegate> {
	SegmentsController     *mSegmentsController;
    UISegmentedControl     *mSegmentedControl;

    UIWindow *window;
    UINavigationController *navigationController;
	UITabBarController *tabBarController;
	
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}
@property (nonatomic, retain) SegmentsController     *segmentsController;
@property (nonatomic, retain) UISegmentedControl     * segmentedControl;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

@end

