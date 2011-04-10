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
#pragma mark -
#pragma mark Util

+(IncomingProcessor *)processorWithDelegate:(id<IncomingProcessorDelegate>)delegate
{
	IncomingProcessor *processor = [[IncomingProcessor alloc] init];
	processor.incomingProcessorDelegate = delegate;
	return processor;
}

- (NSOperation*)taskWithData:(id)data {
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
																		 selector:@selector(processIncomingNetworkText:) object:data] autorelease];
	//[theOp start];
	return theOp;
}

-(void)initiateGrabNewRestaurants:(NSArray *)newRestaurantIds {
	NSMutableString *query = [NSMutableString stringWithFormat:@"%@%@", NETWORKHOST, @"/api/restaurantDetail?"];
	
	for (NSNumber *n in newRestaurantIds) {
		[query appendString:[NSString stringWithFormat:@"id[]=%@&", n]];
	}
	
	DLog(@"(************************************ %@", mManagedObjectContext);
	DLog(@"Need to notify the main thread that we are done processing the dishes and that it's time to now hit the API to get restaurant detail for our list of new restaurants");
	//[[NSNotificationCenter defaultCenter] postNotification:NSNotificationStringDoneProcessingDishes];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newRestaurantIds forKey:@"restaurantIds"];
	[[NSNotificationCenter defaultCenter] postNotificationName:NSNotificationStringDoneProcessingDishes object:self userInfo:userInfo];

}

-(void)processIncomingDishesWithJsonArray:(NSArray *)dishesArray {

	DLog(@"PROCESSOR processIncomingDishes hopefully in another thread. There are %d dishes", [dishesArray count]);
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	NSMutableArray *newRestaurantsWeNeedToGet = [NSMutableArray array];
	for (NSDictionary *dishDict in dishesArray) {
		//   query the datastore
		DLog(@"set up a fetch for dish %d:%@", 
			  [dishDict objectForKey:@"id"], 
			  [dishDict objectForKey:@"name"]);

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
		
		DLog(@"dish fetch done");
		
		Dish *dish;
		//   if it exists, update
		if ([dishesMatching count] == 1) {
			dish = [dishesMatching objectAtIndex:0];
		}		
		//   else 
		else if ([dishesMatching count] == 0) {
			//       add it
			DLog(@"create the dish since it's the first time we've seen it");
			dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
														 inManagedObjectContext:mManagedObjectContext];
			DLog(@"done creating dish");

		}
		else
			NSAssert(TRUE, @"Too many dishes matched a query which should have returned 1");

		DLog(@"associate this dish with it's data from JSON %@");
		[dish setDish_id:[dishDict objectForKey:@"id"]];
		
		[dish setObjName:[NSString stringWithFormat:@"%@", [dishDict objectForKey:@"name"]]];
		[dish setDish_description:[dishDict objectForKey:@"description"]];
		[dish setLatitude:[dishDict objectForKey:@"latitude"]];
		[dish setLongitude:[dishDict objectForKey:@"longitude"]];
		[dish setNegReviews:[dishDict objectForKey:@"negReviews"]];
		[dish setPhotoURL:[dishDict objectForKey:@"photoURL"]];
		[dish setPosReviews:[dishDict objectForKey:@"posReviews"]];
		
		CLLocation *l = [[CLLocation alloc] initWithLatitude:[[dish latitude] floatValue] longitude:[[dish longitude] floatValue]];
		CLLocationDistance dist = [l distanceFromLocation:[[AppModel instance] currentLocation]];
		[l release];
		float distanceInMiles = dist/kOneMileInMeters; 
		NSAssert(distanceInMiles > 0, @"the distance is not > 0");

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
		NSAssert([dish price], @"price must not be null");

		DLog(@"dish is all set up, now fetch for restaurant %d", [dishDict objectForKey:@"restaurantID"]);
		
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
		
		DLog(@"restaurnat fetch done");
		
		Restaurant *restaurant;
		//   if it exists, update
		if ([restosMatching count] == 1) {
			restaurant = [restosMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restosMatching count] == 0) {
			DLog(@"create a new restaurant since it's the first time we've seen it");
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																	 inManagedObjectContext:mManagedObjectContext];	
			[newRestaurantsWeNeedToGet addObject:[dishDict objectForKey:@"restaurantID"]];
			DLog(@"done creating the new restaurant");
		}
		else
			NSAssert(TRUE, @"Too many restaurants for a given dish when queried");
		
		[restaurant setRestaurant_id:[dishDict objectForKey:@"restaurantID"]];
		[restaurant setObjName:[NSString stringWithFormat:@"%@", [dishDict objectForKey:@"restaurantName"]]];
		
		//Should be no extra work setting lat/long and distance
		[restaurant setLatitude:[dishDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[dishDict objectForKey:@"longitude"]];
		[restaurant setDistance:[NSNumber numberWithFloat:distanceInMiles]];
		
		[dish setRestaurant:restaurant];
		DLog(@"done linking the restaurant and the dish");
	}
	NSError *error;
	
	//Only if we have new dishes (we won't if we only got restaurants
	if ([dishesArray count]) {
		DLog(@"save the restaurant");
		if(![mManagedObjectContext save:&error]){
			DLog(@"there was a core data error when saving incoming dishes");
			DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
		}
		else {
			DLog(@"the save was successful, notify the main thread that the save worked, not waiting until done");
			[self.incomingProcessorDelegate saveComplete];
		}

	}
	
	DLog(@"PROCESSOR done processing dishes, given list of new restaurants...");

	//For all of the new restaurants we just created, go fetch their data
	if ([newRestaurantsWeNeedToGet count] > 0) {
		DLog(@"PROCESSOR we have dishes. Do something with them...Currently do nothing");

		[self initiateGrabNewRestaurants:newRestaurantsWeNeedToGet];
	}
	else {
		DLog(@"PROCESSOR no new restaurants");
	}
}

-(void)processIncomingRestaurantsWithJsonArray:(NSArray *)restoArray {
	DLog(@"PROCESSOR processIncomingRestaurants hopefully in another thread. There are %d restaurants", [restoArray count]);

	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	for (NSDictionary *restoDict in restoArray) {
		//   query the datastore
		DLog(@"set up a fetch for restaurant %d:%@", [restoDict objectForKey:@"id"], [restoDict objectForKey:@"name"]);
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
		DLog(@"done with the fetch");
		Restaurant *restaurant;
		//   if it exists, update
		if ([restoMatching count] == 1) {
			restaurant = [restoMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restoMatching count] == 0) {
			//       add it
			DLog(@"create this new restaurant, we've never seen it before aka fetch was empty");
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																	 inManagedObjectContext:mManagedObjectContext];
			DLog(@"done creating restaurant");
		}
		else
			NSAssert(TRUE, @"There were too many restaurants matching a dish");
		DLog(@"populate the restaurant with data");
		
		//Do all of the restaurant data setting
		[restaurant setRestaurant_id:[restoDict objectForKey:@"id"]];
		[restaurant setObjName:[NSString stringWithFormat:@"%@", [restoDict objectForKey:@"name"]]];
		[restaurant setLatitude:[restoDict objectForKey:@"latitude"]];
		[restaurant setLongitude:[restoDict objectForKey:@"longitude"]];
		[restaurant setPhone:[restoDict objectForKey:@"phone"]];
		[restaurant setPhotoURL:[restoDict objectForKey:@"photoURL"]];
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
		DLog(@"done setting up the restaurant with it's data");
		
		for (NSDictionary *restoDishesDict in [restoDict objectForKey:@"dishes"]) {
			//query it's Dishes
			DLog(@"for each dish at this restaurant: fetch this dish %d:%@", 
				  [restoDishesDict objectForKey:@"id"], 
				  [restoDishesDict objectForKey:@"name"]);
			
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
			
			DLog(@"The fetch is done");
			
			Dish *dish;
			//   if it exists, update
			if ([restosDishesMatching count] == 1) {
				dish = [restosDishesMatching objectAtIndex:0];
			}		
			//   else 
			else if ([restosDishesMatching count] == 0) {
				DLog(@"the dish did not exist, create it");
				dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
															 inManagedObjectContext:mManagedObjectContext];		
				DLog(@"dish creation done");
			}
			else 
				NSAssert(TRUE, @"Too many dishes matching a given restaurant");

			DLog(@"populate/update the dish");
			[dish setDish_description:[restoDishesDict objectForKey:@"description"]];
			[dish setDish_id:[restoDishesDict objectForKey:@"id"]];
			[dish setLatitude:[restoDishesDict objectForKey:@"latitude"]];
			[dish setLongitude:[restoDishesDict objectForKey:@"longitude"]];
			[dish setObjName:[NSString stringWithFormat:@"%@", [restoDishesDict objectForKey:@"name"]]];
			[dish setNegReviews:[restoDishesDict objectForKey:@"negReviews"]];
			[dish setPhotoURL:[restoDishesDict objectForKey:@"photoURL"]];
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
			NSAssert([dish price], @"price must not be null");
		}
	}
	NSError *error;
	DLog(@"saving restaurants with all of their dishes");
	if(![mManagedObjectContext save:&error]){
		DLog(@"there was a core data error when saving incoming restaurants");
		DLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
	else {
		DLog(@"successful save, notify on the main thread");
		
		[self.incomingProcessorDelegate saveComplete];
		//I don't think this is the best solution, but it certainly covers it up.
		//if([mIncomingProcessorDelegate respondsToSelector:@selector(saveComplete)]) {
//			[mIncomingProcessorDelegate performSelectorOnMainThread:@selector(saveComplete) 
//														 withObject:nil
//													  waitUntilDone:NO];
//		}
		DLog(@"done notifying the main thread, we didn't wait for it");
	}
}

-(void)processIncomingNetworkText:(NSString *)responseText {

	//First thing is first, create the managed object context:
	//One managed object context per thread. Since Incoming Processor represents a thread,
	//then it gets its own managed object context
	
	//We must create this in the new thread AFTER the init. Not within the init. AFTER the init. 
	//It seems that the init is happening in the main thread, we are not in the new thread until here
	//reference http://www.duckrowing.com/2010/03/11/using-core-data-on-multiple-threads/
	NSPersistentStoreCoordinator *coordinator = [(TopDishAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
    if (coordinator != nil) {
        mManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [mManagedObjectContext setPersistentStoreCoordinator:coordinator];
		[mManagedObjectContext setMergePolicy:NSOverwriteMergePolicy];

    }
	
	//TODO in AddDishViewController, we are already parsing to JSON #optimization
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		DLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[parser release];
		return;
	}
	
	if(error != nil){
		DLog(@"jsoning error %@", error);
		DLog(@"the offensive json %@", responseText);
		NSAssert(NO, @"bad json");
	}
	DLog(@"1) the retain count for self is %d, responseAsDict %d", [self retainCount], [responseAsDictionary retainCount]);

	[self processIncomingDishesWithJsonArray:[responseAsDictionary objectForKey:@"dishes"]];
	DLog(@"2) the retain count for self is %d, responseAsDict %d", [self retainCount], [responseAsDictionary retainCount]);
	[self processIncomingRestaurantsWithJsonArray:[responseAsDictionary objectForKey:@"restaurants"]];
	[parser release];
	
	//[self updateFetch];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)dealloc {
	[mManagedObjectContext release];
	[super dealloc];
}


@end
