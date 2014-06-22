//
//  ABFileSystemManager.m
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABFileSystemManager.h"

@interface ABFileSystemManager ()
@property (strong, nonatomic) NSArray *availableDirectories;
@end

@implementation ABFileSystemManager

- (instancetype)init
{
    if (self = [super init]) {
        // TODO: read available directories from user preferences.
    }
    return self;
}

- (NSArray *)availableDirectories
{
    // TODO: a real implementation
    return @[@"~/"];
}

// TODO: set up ability to set available user directories
- (void)setAvailableDirectories:(NSArray *)availableDirectories
{
    self.availableDirectories = availableDirectories;
    // TODO: write available directories to user preferences.
}

@end
