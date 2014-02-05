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

- (NSImage *)captureMainDisplay
{
    CGImageRef image = CGDisplayCreateImage(kCGDirectMainDisplay);
    NSImage *screenshot = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
    CGImageRelease(image);
    
    return screenshot;
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.window close];
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

@end
