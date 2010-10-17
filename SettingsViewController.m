//
//  SettingsViewController.m
//
//  Created by Roderic Campbell on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsView
@synthesize refineButton;
@synthesize maxSlider;
@synthesize minSlider;
@synthesize maxLabel;
@synthesize minLabel;
@synthesize delegate;

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
							  nil] ;
	
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
