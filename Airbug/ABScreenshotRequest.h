//
//  ABScreenshotRequest.h
//  Airbug
//
//  Created by Richard Shin on 5/26/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScreenshotRequest : NSObject

typedef NS_ENUM(NSUInteger, ABScreenshotType) {
    ABUnknownScreenshotType = 0,
    ABFullScreenScreenshotType = 1,
    ABCrosshairScreenshotType,
    ABTimedScreenshotType
};

@property (nonatomic) ABScreenshotType type;

+ (ABScreenshotType)typeFromString:(NSString *)screenshotType;

@end
