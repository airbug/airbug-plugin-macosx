//
//  ABWebViewWindowController.m
//  Airbug
//
//  Created by Richard Shin on 5/15/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABWebViewWindowController.h"
#import "ABWebViewWindow.h"

@interface ABWebViewWindowController ()
@end

@implementation ABWebViewWindowController

- (id)init
{
    return [super initWithWindowNibName:[self windowNibName] owner:self];
}

#pragma mark - Public methods

- (NSString *)windowNibName {
    return @"ABWebViewWindow";
}

@end
