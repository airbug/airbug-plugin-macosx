//
//  ABScreenCapturer.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCapture.h"

@interface ABScreenCapture ()
@property (strong, nonatomic) NSWindow *window;
@end

@implementation ABScreenCapture

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

- (void)displayOverlayOnMainDisplay
{
    NSScreen *screen = [NSScreen screens][0];
    NSWindow *window = [[NSWindow alloc] initWithContentRect:screen.frame
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:screen];
    window.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    int windowLevel = CGShieldingWindowLevel();
    [window setLevel:windowLevel];
    [window setAlphaValue:1.0];
    [window setOpaque:NO];
    [window setIgnoresMouseEvents:NO];
    [window setReleasedWhenClosed:NO];
    [window makeKeyAndOrderFront:nil];
    [NSThread sleepForTimeInterval:1.0];
    [window close];
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
