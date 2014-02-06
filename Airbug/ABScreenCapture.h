//
//  ABScreenCapturer.h
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScreenCapture : NSObject

- (NSImage *)captureMainScreen;
- (NSImage *)captureScreen:(NSScreen *)screen;

@end
