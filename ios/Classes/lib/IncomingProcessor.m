//
//  IncomingProcessor.m
//  TopDish
//
//  Created by roderic campbell on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IncomingProcessor.h"
#import "SBJSON.h"
#import "Dish.h"
#import "Restaurant.h"
#import "AppModel.h"
#import "constants.h"

@implementation IncomingProcessor

@synthesize responseData = mResponseData;
@synthesize incomingProcessorDelegate = mIncomingProcessorDelegate;
@synthesize persistentStoreCoordinator = mPersistentStoreCoordinator;
#pragma mark -
#pragma mark Util

+(IncomingProcessor *)processorWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator
													 Delegate:(id<IncomingProcessorDelegate>)delegate
{
	IncomingProcessor *processor = [[IncomingProcessor alloc] init];
	processor.incomingProcessorDelegate = delegate;
	processor.persistentStoreCoordinator = coordinator;
	return [processor autorelease];
}

- (NSOperation*)taskWithData:(id)data {
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
																		 selector:@selector(processIncomingNetworkText:) object:data] autorelease];
	return theOp;
}

-(void)processIncomingDishesWithJsonArray:(NSArray *)dishesArray {

	DLog(@"processIncomingDishes. There are %d dishes", [dishesArray count]);
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	NSMutableArray *newRestaurantsWeNeedToGet = [NSMutableArray array];
	for (NSDictionary *dishDict in dishesArray) {
		//   query the datastore
		NSFetchRequest *dishFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Dish" 
													 inManagedObjectContext:mManagedObjectContext];
		NSPredicate *dishFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
								   [dishDict objectForKey:@"id"]];
		
		[dishFetchRequest setEntity:whichType];
		
		[dishFetchRequest setPredicate:dishFilter];
		NSError *error;
		NSArray *dishesMatching = [mManagedObjectContext
								   executeFetchRequest:dishFetchRequest error:&error];
		[dishFetchRequest release];
				
		Dish *dish;
		//   if it exists, update
		if ([dishesMatching count] == 1) {
			//Existing dish
			dish = [dishesMatching objectAtIndex:0];
		}		
		//   else 
		else if ([dishesMatching count] == 0) {
			//       add it
			//create the dish since it's the first time we've seen it
			dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
														 inManagedObjectContext:mManagedObjectContext];
		}
		else {
			NSAssert(TRUE, @"Too many dishes matched a query which should have returned 1");
			dish = nil;
		}

		[dish setDish_id:[dishDict objectForKey:@"id"]];	
		
		NSString *unescaped_name = [[dishDict objectForKey:@"name"] 
									stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[dish setObjName:unescaped_name];
		[dish setDish_description:[dishDict objectForKey:@"description"]];
		[dish setLatitude:[dishDict objectForKey:@"latitude"]];
		[dish setLongitude:[dishDict objectForKey:@"longitude"]];
		[dish setNegReviews:[dishDict objectForKey:@"negReviews"]];
		
		//https://projects.topdish.com/redmine/issues/90
		//TODO: i'm currently only taking the first image. It's the 90% rule.
		NSArray *photoURLArray = [dishDict objectForKey:@"photoURL"];
		
        if ([photoURLArray count] && ![dish.photoURL isEqualToString:[photoURLArray objectAtIndex:0]]) {
            [dish setPhotoURL:[photoURLArray count] > 0 ? [photoURLArray objectAtIndex:0]: @""];
        }
		///////
		
		[dish setPosReviews:[dishDict objectForKey:@"posReviews"]];
		
		CLLocation *l = [[CLLocation alloc] initWithLatitude:[[dish latitude] floatValue] longitude:[[dish longitude] floatValue]];
		CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
		[l release];
		float distanceInMiles = dist/kOneMileInMeters; 

		[dish setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
		NSArray *tagsArray = [dishDict objectForKey:@"tags"];
		for (NSDictionary *tag in tagsArray){
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kMealTypeString] )
				[dish setMealType:[tag objectForKey:@"id"]];
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kPriceTypeString] )
				[dish setPrice:[tag objectForKey:@"id"]];			
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kLifestyleTypeString] )
				[dish setLifestyleType:[tag objectForKey:@"id"]];			
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kCuisineTypeString] )
				[dish setCuisineType:[tag objectForKey:@"id"]];
			if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kAllergenTypeString] )
				[dish setAllergenType:[tag objectForKey:@"id"]];
		}	
		NSAssert([dish price],([NSString stringWithFormat:@"%@ - %@", @"price must not be null", dish]));
		
		//query it's restaurant
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		whichType = [NSEntityDescription entityForName:@"Restaurant" 
								inManagedObjectContext:mManagedObjectContext];
		NSPredicate *restaurantFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
										 [dishDict objectForKey:@"restaurantID"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restaurantFilter];
		NSArray *restosMatching = [mManagedObjectContext
								   executeFetchRequest:restoFetchRequest error:&error];
		[restoFetchRequest release];

		Restaurant *restaurant;
		//   if it exists, update
		if ([restosMatching count] == 1) {
			restaurant = [restosMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restosMatching count] == 0) {
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																	 inManagedObjectContext:mManagedObjectContext];	
			[newRestaurantsWeNeedToGet addObject:[dishDict objectForKey:@"restaurantID"]];
		}
		else {
			NSAssert(TRUE, @"Too many restaurants for a given dish when queried");
			restaurant = nil;
		}
		
		[restaurant setRestaurant_id:[dishDict objectForKey:@"restaurantID"]];
		
		unescaped_name = [[dishDict objectForKey:@"restaurantName"]
						  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[restaurant setObjName:unescaped_name];
		
		//Should be no extra work setting lat/long and distance
		[restaurant setLatitude:[dishDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[dishDict objectForKey:@"longitude"]];
		[restaurant setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
		[dish setRestaurant:restaurant];
	}
	NSError *error;
	
	//Only if we have new dishes (we won't if we only got restaurants
	if ([dishesArray count]) {
		if(![mManagedObjectContext save:&error]){
			DLog(@"there was a core data error when saving incoming dishes");
			DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
		}
		else {
			//the save was successful, notify the main thread that the save worked, not waiting until done
			[self.incomingProcessorDelegate saveDishesComplete:newRestaurantsWeNeedToGet];
		}
	}
}

-(void)processIncomingRestaurantsWithJsonArray:(NSArray *)restoArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	for (NSDictionary *restoDict in restoArray) {
		//   query the datastore
		//set up a fetch for this current restaurant
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Restaurant" 
													 inManagedObjectContext:mManagedObjectContext];
		NSPredicate *restoFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
									[restoDict objectForKey:@"id"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restoFilter];
		NSError *error;
		NSArray *restoMatching = [mManagedObjectContext
								  executeFetchRequest:restoFetchRequest error:&error];
		[restoFetchRequest release];

		Restaurant *restaurant;
		//   if it exists, update
		if ([restoMatching count] == 1) {
			//restomatching count is 1, good sign
			restaurant = [restoMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restoMatching count] == 0) {
			//       add it
			//create this new restaurant, we've never seen it before aka fetch was empty
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																	 inManagedObjectContext:mManagedObjectContext];
		}
		else {
			NSAssert(TRUE, @"There were too many restaurants matching a dish");
			restaurant = nil;
		}
		//populate the restaurant with data
		//Do all of the restaurant data setting
		NSString *unescaped_name = [[restoDict objectForKey:@"name"]
									stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		[restaurant setRestaurant_id:[restoDict objectForKey:@"id"]];
		[restaurant setObjName:unescaped_name];
		[restaurant setLatitude:[restoDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[restoDict objectForKey:@"longitude"]];
		[restaurant setPhone:[restoDict objectForKey:@"phone"]];
		
		
		//https://projects.topdish.com/redmine/issues/90
		//TODO: i'm currently only taking the first image. It's the 90% rule.
		NSArray *photoURLArray = [restoDict objectForKey:@"photoURL"];
        
        //If the photo is a new photo...
        if ([photoURLArray count] && ![restaurant.photoURL isEqualToString:[photoURLArray objectAtIndex:0]]) {
            [restaurant setPhotoURL:[photoURLArray count] > 0 ? [photoURLArray objectAtIndex:0]: @""];
        }
		///////
		
		[restaurant setAddressLine1:[restoDict objectForKey:@"addressLine1"]];
		[restaurant setAddressLine2:[restoDict objectForKey:@"addressLine2"]];
		[restaurant setCity:[restoDict objectForKey:@"city"]];
		[restaurant setState:[restoDict objectForKey:@"state"]];
		
		CLLocation *l = [[CLLocation alloc] initWithLatitude:[[restaurant latitude] floatValue] longitude:[[restaurant longitude] floatValue]];
		CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
		[l release];
		float distanceInMiles = dist/kOneMileInMeters; 
		NSAssert(distanceInMiles > 0, @"the distance is not > 0");
		
		[restaurant setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		//done setting up the restaurant with it's data
		
		for (NSDictionary *restoDishesDict in [restoDict objectForKey:@"dishes"]) {
			//query it's Dishes
			NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
			whichType = [NSEntityDescription entityForName:@"Dish" 
									inManagedObjectContext:mManagedObjectContext];
			NSPredicate *restosDishesFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
											   [restoDishesDict objectForKey:@"id"]];
			
			[restoFetchRequest setEntity:whichType];
			
			[restoFetchRequest setPredicate:restosDishesFilter];
			NSArray *restosDishesMatching = [mManagedObjectContext
											 executeFetchRequest:restoFetchRequest error:&error];
			[restoFetchRequest release];

			Dish *dish;
			//   if it exists, update
			if ([restosDishesMatching count] == 1) {
				dish = [restosDishesMatching objectAtIndex:0];
			}		
			//   else 
			else if ([restosDishesMatching count] == 0) {
				//the dish did not exist, create it
				dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
															 inManagedObjectContext:mManagedObjectContext];		
			}
			else {
				NSAssert(TRUE, @"Too many dishes matching a given restaurant");
				dish = nil;
			}

			//populate/update the dish
			NSString *unescaped_name = [[restoDishesDict objectForKey:@"name"]
										stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			[dish setDish_description:[restoDishesDict objectForKey:@"description"]];
			[dish setDish_id:[restoDishesDict objectForKey:@"id"]];
			[dish setLatitude:[restoDishesDict objectForKey:@"latitude"]];
			[dish setLongitude:[restoDishesDict objectForKey:@"longitude"]];
			[dish setObjName:unescaped_name];
			[dish setNegReviews:[restoDishesDict objectForKey:@"negReviews"]];
			
			//https://projects.topdish.com/redmine/issues/90
			//TODO: i'm currently only taking the first image. It's the 90% rule.
			NSArray *photoURLArray = [restoDishesDict objectForKey:@"photoURL"];
            
            //If we have a new image, replace it
            if ([photoURLArray count] && ![restaurant.photoURL isEqualToString:[photoURLArray objectAtIndex:0]]) {
                [dish setPhotoURL:[photoURLArray count] > 0 ? [photoURLArray objectAtIndex:0]: @""];
            }
			///////
			
			[dish setPosReviews:[restoDishesDict objectForKey:@"posReviews"]];
			[dish setRestaurant:restaurant];
			[dish setDistance:restaurant.distance];
			dish.distance = restaurant.distance;
			
			NSArray *tagsArray = [restoDishesDict objectForKey:@"tags"];
			for (NSDictionary *tag in tagsArray){
				if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kMealTypeString] )
					[dish setMealType:[tag objectForKey:@"id"]];
				if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kPriceTypeString] )
					[dish setPrice:[tag objectForKey:@"id"]];			
				if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kLifestyleTypeString] )
					[dish setLifestyleType:[tag objectForKey:@"id"]];			
				if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kCuisineTypeString] )
					[dish setCuisineType:[tag objectForKey:@"id"]];
				if ([(NSString *)[tag objectForKey:@"type"] isEqualToString:kAllergenTypeString] )
					[dish setAllergenType:[tag objectForKey:@"id"]];
			}	
			NSAssert([dish price],([NSString stringWithFormat:@"%@ - %@", @"price must not be null", dish]));
		}
	}

	//saving restaurants with all of their dishes");
	NSError *error;
	if(![mManagedObjectContext save:&error]){
		DLog(@"there was a core data error when saving incoming restaurants");
		DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	else {
		//successful save of the restaurants, notify on the main thread		
		[self.incomingProcessorDelegate saveRestaurantsComplete];
	}
}

-(void)processIncomingNetworkText:(NSString *)responseText {

	//First thing is first, create the managed object context:
	//One managed object context per thread. Since Incoming Processor represents a thread,
	//then it gets its own managed object context
	
	//We must create this in the new thread AFTER the init. Not within the init. AFTER the init. 
	//It seems that the init is happening in the main thread, we are not in the new thread until here
	//reference http://www.duckrowing.com/2010/03/11/using-core-data-on-multiple-threads/
    if (self.persistentStoreCoordinator != nil) {
        mManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [mManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
		[mManagedObjectContext setMergePolicy:NSOverwriteMergePolicy];

    }
	
	//TODO in AddDishViewController, we are already parsing to JSON #optimization
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		[parser release];
		if ([self.incomingProcessorDelegate respondsToSelector:@selector(saveError:)])
			[self.incomingProcessorDelegate saveError:[responseAsDictionary objectForKey:@"message"]];
		return;
	}
	
	if(error != nil){
		DLog(@"JSON Error: the offensive json %@", responseText);
		if ([self.incomingProcessorDelegate respondsToSelector:@selector(saveError:)])
			[self.incomingProcessorDelegate saveError:@"Bad data from the Server"];

		NSAssert(NO, @"bad json");
	}

	[self processIncomingDishesWithJsonArray:[responseAsDictionary objectForKey:@"dishes"]];
	[self processIncomingRestaurantsWithJsonArray:[responseAsDictionary objectForKey:@"restaurants"]];
	[parser release];
	self.incomingProcessorDelegate = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)dealloc {
	[mManagedObjectContext release];
	self.persistentStoreCoordinator = nil;
	self.incomingProcessorDelegate = nil;
	[super dealloc];
}


@end
