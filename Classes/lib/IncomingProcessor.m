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


#pragma mark -
#pragma mark Util

-(id)init
{
	self = [super init];
	return self;
}

- (NSOperation*)taskWithData:(id)data {
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
																		 selector:@selector(processIncomingNetworkText:) object:data] autorelease];
	[theOp start];
	return theOp;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	NSString *responseText = [[NSString alloc] initWithData:self.responseData 
												   encoding:NSASCIIStringEncoding];
	
	NSString *responseTextStripped = [responseText stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	//Send this incoming content to the IncomingProcessor Object	
	[self processIncomingNetworkText:responseTextStripped];
	[responseText release];
	self.responseData = nil;
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
#ifndef AirplaneMode
	NSLog(@"connection did fail with error %@", error);
	UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"NetworkError" 
									   message:@"There was a network issue. Try again later" 
									  delegate:self 
							 cancelButtonTitle:@"Ok" 
							 otherButtonTitles:nil]; 
	[alert show];
	[alert release];
#else	
	//Airplane mode must set _responseText
	[self processIncomingNetworkText:DishSearchResponseText];
#endif
	self.responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if(self.responseData == nil){
		self.responseData = [[NSMutableData alloc] initWithData:data];
	}
	else{
		if (data) {
			[self.responseData appendData:data];
		}
	}
}


-(void) networkQuery:(NSString *)query{
	NSURL *url;
	NSURLRequest *request;
	//NSURLConnection *conn;
	url = [NSURL URLWithString:query];
	NSLog(@"url is %@", query);
	//Start up the networking
	request = [NSURLRequest requestWithURL:url];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request 
												delegate:self 
										startImmediately:TRUE];
	[conn release];
}

-(void)initiateGrabNewRestaurants:(NSArray *)newRestaurantIds {
	NSMutableString *query = [NSMutableString stringWithFormat:@"%@%@", NETWORKHOST, @"/api/restaurantDetail?"];
	
	for (NSNumber *n in newRestaurantIds) {
		[query appendString:[NSString stringWithFormat:@"id[]=%@&", n]];
	}
	[self networkQuery:query];	
}

-(void)processIncomingDishesWithJsonArray:(NSArray *)dishesArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	NSMutableArray *newRestaurantsWeNeedToGet = [NSMutableArray array];
	for (NSDictionary *dishDict in dishesArray) {
		//   query the datastore
		NSFetchRequest *dishFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Dish" 
													 inManagedObjectContext:kManagedObjectContect];
		NSPredicate *dishFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
								   [dishDict objectForKey:@"id"]];
		
		[dishFetchRequest setEntity:whichType];
		
		[dishFetchRequest setPredicate:dishFilter];
		NSError *error;
		NSArray *dishesMatching = [kManagedObjectContect
								   executeFetchRequest:dishFetchRequest error:&error];
		[dishFetchRequest release];
		
		Dish *dish;
		//   if it exists, update
		if ([dishesMatching count] == 1) {
			dish = [dishesMatching objectAtIndex:0];
		}		
		//   else 
		else if ([dishesMatching count] == 0) {
			//       add it
			dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
														 inManagedObjectContext:kManagedObjectContect];
		}
		else
			NSAssert(TRUE, @"Too many dishes matched a query which should have returned 1");

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
		float distanceInMiles = dist/1609.344; 
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

		//query it's restaurant
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		whichType = [NSEntityDescription entityForName:@"Restaurant" 
								inManagedObjectContext:kManagedObjectContect];
		NSPredicate *restaurantFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
										 [dishDict objectForKey:@"restaurantID"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restaurantFilter];
		NSArray *restosMatching = [kManagedObjectContect
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
																	 inManagedObjectContext:kManagedObjectContect];	
			[newRestaurantsWeNeedToGet addObject:[dishDict objectForKey:@"restaurantID"]];
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
	}
	NSError *error;
	NSLog(@"saving the incoming dishes");
	
	//Only if we have new dishes (we won't if we only got restaurants
	if ([dishesArray count]) {
		if(![kManagedObjectContect save:&error]){
			NSLog(@"there was a core data error when saving incoming dishes");
			NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
		}
	}
	
	
	//For all of the new restaurants we just created, go fetch their data
	if ([newRestaurantsWeNeedToGet count] > 0) {
		[self initiateGrabNewRestaurants:newRestaurantsWeNeedToGet];
	}
	
	//TODO, send the update fetch to the receiving object
	//[self updateFetch];
	
}

-(void)processIncomingRestaurantsWithJsonArray:(NSArray *)restoArray {
	//we have a list of dishes, for each of them, query the datastore
	//for each dish in the list
	NSLog(@"got a bunch of new restaurants from DishTableViewController, creating those");
	for (NSDictionary *restoDict in restoArray) {
		//   query the datastore
		NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *whichType = [NSEntityDescription entityForName:@"Restaurant" 
													 inManagedObjectContext:kManagedObjectContect];
		NSPredicate *restoFilter = [NSPredicate predicateWithFormat:@"(restaurant_id == %@)", 
									[restoDict objectForKey:@"id"]];
		
		[restoFetchRequest setEntity:whichType];
		
		[restoFetchRequest setPredicate:restoFilter];
		NSError *error;
		NSArray *restoMatching = [kManagedObjectContect
								  executeFetchRequest:restoFetchRequest error:&error];
		[restoFetchRequest release];
		
		Restaurant *restaurant;
		//   if it exists, update
		if ([restoMatching count] == 1) {
			restaurant = [restoMatching objectAtIndex:0];
		}		
		//   else 
		else if ([restoMatching count] == 0) {
			//       add it
			restaurant = (Restaurant *)[NSEntityDescription insertNewObjectForEntityForName:@"Restaurant" 
																	 inManagedObjectContext:kManagedObjectContect];
		}
		else
			NSAssert(TRUE, @"There were too many restaurants matching a dish");
		
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
		
		for (NSDictionary *restoDishesDict in [restoDict objectForKey:@"dishes"]) {
			//query it's Dishes
			NSFetchRequest *restoFetchRequest = [[NSFetchRequest alloc] init];
			whichType = [NSEntityDescription entityForName:@"Dish" 
									inManagedObjectContext:kManagedObjectContect];
			NSPredicate *restosDishesFilter = [NSPredicate predicateWithFormat:@"(dish_id == %@)", 
											   [restoDishesDict objectForKey:@"id"]];
			
			[restoFetchRequest setEntity:whichType];
			
			[restoFetchRequest setPredicate:restosDishesFilter];
			NSArray *restosDishesMatching = [kManagedObjectContect
											 executeFetchRequest:restoFetchRequest error:&error];
			[restoFetchRequest release];
			
			Dish *dish;
			//   if it exists, update
			if ([restosDishesMatching count] == 1) {
				dish = [restosDishesMatching objectAtIndex:0];
			}		
			//   else 
			else if ([restosDishesMatching count] == 0) {
				dish = (Dish *)[NSEntityDescription insertNewObjectForEntityForName:@"Dish" 
															 inManagedObjectContext:kManagedObjectContect];		
			}
			else 
				NSAssert(TRUE, @"Too many dishes matching a given restaurant");

			[dish setDish_description:[restoDishesDict objectForKey:@"description"]];
			[dish setDish_id:[restoDishesDict objectForKey:@"id"]];
			[dish setLatitude:[restoDishesDict objectForKey:@"latitude"]];
			[dish setLongitude:[restoDishesDict objectForKey:@"longitude"]];
			[dish setObjName:[NSString stringWithFormat:@"%@", [restoDishesDict objectForKey:@"name"]]];
			[dish setNegReviews:[restoDishesDict objectForKey:@"negReviews"]];
			[dish setPhotoURL:[restoDishesDict objectForKey:@"photoURL"]];
			[dish setPosReviews:[restoDishesDict objectForKey:@"posReviews"]];
			[dish setRestaurant:restaurant];
			
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
	NSLog(@"saving the incoming restaurants");
	if(![kManagedObjectContect save:&error]){
		NSLog(@"there was a core data error when saving incoming restaurants");
		NSLog(@"Unresolved error %@, \nuser info: %@", error, [error userInfo]);
	}
}



-(void)processIncomingNetworkText:(NSString *)responseText {
	
	//TODO in AddDishViewController, we are already parsing to JSON #optimization
	SBJSON *parser = [SBJSON new];
	NSError *error = nil;
	
	NSDictionary *responseAsDictionary = [parser objectWithString:responseText 
															error:&error];
	if ([[responseAsDictionary objectForKey:@"rc"] intValue] != 0) {
		NSLog(@"message: %@", [responseAsDictionary objectForKey:@"message"]);
		[parser release];
		return;
	}
	
	if(error != nil){
		NSLog(@"there was an error when jsoning");
		NSLog(@"jsoning error %@", error);
		NSLog(@"the offensive json %@", responseText);
	}
	
	[self processIncomingDishesWithJsonArray:[responseAsDictionary objectForKey:@"dishes"]];
	[self processIncomingRestaurantsWithJsonArray:[responseAsDictionary objectForKey:@"restaurants"]];
	[parser release];
	
	//[self updateFetch];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)dealloc {
	self.responseData = nil;
	[super dealloc];
}


@end
