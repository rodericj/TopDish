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

//-(IBAction) closeSettings{
//	[self dismissModalViewControllerAnimated:TRUE]; 
//
//	NSNumber *maxFloatVal = [[NSNumber alloc] initWithFloat:[maxSlider value]];
//	
//	//Create array with sort params, then store in NSUserDefaults
//	NSNumber *anInt = [[NSNumber alloc] initWithInt:[sortBySegmentedControl selectedSegmentIndex]];	
//	[[NSUserDefaults standardUserDefaults] setObject:anInt forKey:SORT_VALUE_LOCATION];
//
//	NSLog(@"close settings %@", [[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION]);
//		
//	[[NSUserDefaults standardUserDefaults] setObject:maxFloatVal forKey:MAX_PRICE_VALUE_LOCATION];
//	[[NSUserDefaults standardUserDefaults] setObject:minFloatVal forKey:MIN_PRICE_VALUE_LOCATION];
//
//	[delegate updateFetch];
//}

- (void) updateSymbols{
	[self.mealTypeLabel setText:[[[AppModel instance] mealTypeTags] objectAtIndex:[self.mealTypeSlider value]]];
	[self.priceLabel setText:[[[AppModel instance] priceTags] objectAtIndex:[self.priceSlider value]]];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
