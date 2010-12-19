//
//  AddNewDish.m
//  TopDish
//
//  Created by roderic campbell on 12/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddNewDish.h"


@implementation AddNewDish
@synthesize label = mLabel;

-(void)viewDidLoad{
	self.label.text = @"hi";
}

- (void)dealloc {
	self.label = nil;
    [super dealloc];
}


@end
