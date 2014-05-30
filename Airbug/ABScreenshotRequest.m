//
//  ABScreenshotRequest.m
//  Airbug
//
//  Created by Richard Shin on 5/26/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenshotRequest.h"

@implementation ABScreenshotRequest

+ (ABScreenshotType)typeFromString:(NSString *)screenshotType
{
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @"FullScreen" : @(ABFullScreenScreenshotType),
                  @"Crosshair" : @(ABCrosshairScreenshotType),
                  @"Timed" : @(ABTimedScreenshotType)
                  };
    }
    if (![[types allKeys] containsObject:screenshotType]) {
        return ABUnknownScreenshotType;
    }
    return [types[screenshotType] integerValue];
}

@end
