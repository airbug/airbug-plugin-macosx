//
//  ABScreenCapturer.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCapturer.h"

@interface ABScreenCapturer ()
@property (strong, nonatomic) NSWindow *window;
@end

@implementation ABScreenCapturer

#pragma mark - Public

- (NSImage *)captureMainScreen
{
    return [self captureScreen:[NSScreen mainScreen]];
}

- (NSImage *)captureScreen:(NSScreen *)screen
{
    if (!screen) return nil;
    NSArray *screens = [NSScreen screens];
    NSUInteger idx = [screens indexOfObject:screen];
    if (idx == NSNotFound) return nil;
    
    NSDictionary *dictionary = screen.deviceDescription;
    CGDirectDisplayID displayID = [dictionary[@"NSScreenNumber"] intValue];
    return [self imageFromDisplayID:displayID];
}

#pragma mark - Private

- (NSImage *)imageFromDisplayID:(CGDirectDisplayID)displayID
{
    CGImageRef imageRef = CGDisplayCreateImage(displayID);
    NSImage *image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
    CGImageRelease(imageRef);
    return image;
}

@end
