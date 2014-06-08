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
                  @"FullScreen" : @(ABScreenshotTypeFullScreen),
                  @"Crosshair" : @(ABScreenshotTypeCrosshair),
                  @"Timed" : @(ABScreenshotTypeTimed)
                  };
    }
    if (![[types allKeys] containsObject:screenshotType]) {
        return ABScreenshotTypeUnknown;
    }
    return [types[screenshotType] integerValue];
}

+ (NSString *)stringFromType:(ABScreenshotType)screenshotType
{
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @(ABScreenshotTypeFullScreen) : @"FullScreen",
                  @(ABScreenshotTypeCrosshair) : @"Crosshair",
                  @(ABScreenshotTypeTimed) : @"Timed"
                  };
    }
    if (![[types allKeys] containsObject:@(screenshotType)]) {
        return @"Unknown";
    }
    return types[@(screenshotType)];
}

@end
