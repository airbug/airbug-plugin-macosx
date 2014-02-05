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

- (NSImage *)captureMainDisplay
{
    CGImageRef image = CGDisplayCreateImage(kCGDirectMainDisplay);
    NSImage *screenshot = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
    CGImageRelease(image);
    
    NSScreen *screen = [NSScreen screens][0];
    self.window = [[NSWindow alloc] initWithContentRect:screen.frame
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:screen];
    self.window.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    int windowLevel = CGShieldingWindowLevel();
    [self.window setLevel:windowLevel];
    [self.window setAlphaValue:1.0];
    [self.window setOpaque:NO];
    [self.window setIgnoresMouseEvents:NO];
    [self.window setReleasedWhenClosed:NO];
    [self.window makeKeyAndOrderFront:nil];
    
    NSDictionary *fadeAnimation = @{NSViewAnimationTargetKey : self.window,
                                    NSViewAnimationEffectKey : NSViewAnimationFadeOutEffect};
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[fadeAnimation]];
    animation.duration = 1.0;
    animation.delegate = self;
    [animation startAnimation];
    
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
