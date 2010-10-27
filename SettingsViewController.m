//
//  SettingsViewController.m
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "constants.h"

@implementation SettingsView
@synthesize refineButton;
@synthesize maxSlider;
@synthesize minSlider;
@synthesize maxLabel;
@synthesize minLabel;
@synthesize sortBySegmentedControl;
@synthesize delegate;


- (void)viewWillAppear:(BOOL)animated {
	
	//We need to maintain the previous state of the slider values.
	NSNumber *value = [[NSNumber alloc] initWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION] intValue]];
	[sortBySegmentedControl setSelectedSegmentIndex:[value intValue]];
	[minSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:MIN_PRICE_VALUE_LOCATION] floatValue]];
	[maxSlider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:MAX_PRICE_VALUE_LOCATION] floatValue]];
	[self updateSymbols];
}

-(IBAction) updateMaxSlider{
	//make the slider appear rigid
	[maxSlider setValue:(int)[maxSlider value]];
	
	//Ensure minimum slider is 
	if([minSlider value] > [maxSlider value]){
		[minSlider setValue:[maxSlider value]];
	}
	[self updateSymbols];
}

-(IBAction) updateMinSlider{
	//Make the slider appear rigid
	[minSlider setValue:(int)[minSlider value]];

	if([minSlider value] > [maxSlider value]){
		[maxSlider setValue:[minSlider value]];
	}
	[self updateSymbols];
}

-(IBAction) closeSettings{
	[self dismissModalViewControllerAnimated:TRUE]; 

	NSNumber *minFloatVal = [[NSNumber alloc] initWithFloat:[minSlider value]];
	NSNumber *maxFloatVal = [[NSNumber alloc] initWithFloat:[maxSlider value]];
	//NSFloat *maxFloatVal = [[NSInteger alloc] initWithFloat:[maxSlider value]];
	
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  maxFloatVal, @"maxPrice",
							  minFloatVal, @"minPrice",
							  nil];
	//Create array with sort params, then store in NSUserDefaults
	//NSString *sorter = [[NSArray arrayWithObjects:RATINGS_SORT, DISTANCE_SORT, nil] objectAtIndex:[sortBySegmentedControl selectedSegmentIndex]];
	NSNumber *anInt = [[NSNumber alloc] initWithInt:[sortBySegmentedControl selectedSegmentIndex]];	
	[[NSUserDefaults standardUserDefaults] setObject:anInt forKey:SORT_VALUE_LOCATION];

	NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:SORT_VALUE_LOCATION]);
		
	[[NSUserDefaults standardUserDefaults] setObject:maxFloatVal forKey:MAX_PRICE_VALUE_LOCATION];
	[[NSUserDefaults standardUserDefaults] setObject:minFloatVal forKey:MIN_PRICE_VALUE_LOCATION];

	[delegate updateSettings:settings];
}

- (void) updateSymbols{
	NSMutableString *output = [NSMutableString stringWithCapacity:[maxSlider value]];
		
	for (int i = 0; i < [maxSlider value]; i++)
		[output appendString:@"$"];
	
	[maxLabel setText:output];
	
	output = [NSMutableString stringWithCapacity:[minSlider value]];
	
	for (int i = 0; i < [minSlider value]; i++)
		[output appendString:@"$"];
	
	[minLabel setText:output];
}

- (void)dealloc {
    [super dealloc];
}


@end
