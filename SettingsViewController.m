//
//  SettingsViewController.m
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "constants.h"
#import "AppModel.h"

@implementation SettingsView
@synthesize refineButton;
@synthesize mealTypeSlider = mMealTypeSlider;
@synthesize priceSlider = mPriceSlider;
@synthesize mealTypeLabel = mMealTypeLabel;
@synthesize priceLabel = mPriceLabel;
@synthesize sortBySegmentedControl;
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated {
	
	NSLog(@"the stuff from the appModel %@, %@", [[AppModel instance] mealTypeTags], [[AppModel instance] priceTags]);
	[self.mealTypeSlider setMaximumValue:[[[AppModel instance] mealTypeTags] count]- 1];
	[self.priceSlider setMaximumValue:[[[AppModel instance] priceTags] count]- 1];
	
	[self.mealTypeSlider setMinimumValue:0];
	[self.priceSlider setMinimumValue:0];
	
	//We need to maintain the previous state of the slider values.
	//NSNumber *value = [[NSNumber alloc] initWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION] intValue]];
//	[sortBySegmentedControl setSelectedSegmentIndex:[value intValue]];
//	[self.priceSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:MIN_PRICE_VALUE_LOCATION] floatValue]];
//	[self.mealTypeSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:MAX_PRICE_VALUE_LOCATION] floatValue]];
	[self updateSymbols];
}

-(IBAction) updateMealType{
	//make the slider appear rigid
	[self.mealTypeSlider setValue:(int)[self.mealTypeSlider value]];
	
	[self updateSymbols];
}

-(IBAction) updatePriceTags{
	//Make the slider appear rigid
	[self.priceSlider setValue:(int)[self.priceSlider value]];

	[self updateSymbols];
}

-(IBAction) cancelSettings{
	[self dismissModalViewControllerAnimated:TRUE]; 
}

-(IBAction) closeSettings{
	[self dismissModalViewControllerAnimated:TRUE]; 

	//NSNumber *minFloatVal = [[NSNumber alloc] initWithFloat:[minSlider value]];
//	NSNumber *maxFloatVal = [[NSNumber alloc] initWithFloat:[maxSlider value]];
//	//NSFloat *maxFloatVal = [[NSInteger alloc] initWithFloat:[maxSlider value]];
//	
//	//Create array with sort params, then store in NSUserDefaults
//	//NSString *sorter = [[NSArray arrayWithObjects:RATINGS_SORT, DISTANCE_SORT, nil] objectAtIndex:[sortBySegmentedControl selectedSegmentIndex]];
//	NSNumber *anInt = [[NSNumber alloc] initWithInt:[sortBySegmentedControl selectedSegmentIndex]];	
//	[[NSUserDefaults standardUserDefaults] setObject:anInt forKey:SORT_VALUE_LOCATION];
//
//	NSLog(@"close settings %@", [[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION]);
//		
//	[[NSUserDefaults standardUserDefaults] setObject:maxFloatVal forKey:MAX_PRICE_VALUE_LOCATION];
//	[[NSUserDefaults standardUserDefaults] setObject:minFloatVal forKey:MIN_PRICE_VALUE_LOCATION];
//
	[delegate updateFetch];
}

- (void) updateSymbols{
	[self.mealTypeLabel setText:[[[AppModel instance] mealTypeTags] objectAtIndex:[self.mealTypeSlider value]]];
	[self.priceLabel setText:[[[AppModel instance] priceTags] objectAtIndex:[self.priceSlider value]]];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
