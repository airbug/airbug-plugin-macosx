//
//  ABScreenCaptureController.m
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCaptureController.h"
#import "ABScreenCapture.h"

@interface ABScreenCaptureController ()
@property (strong, nonatomic) ABScreenCapture *capture;
@property (strong, nonatomic) NSWindow *flashWindow;
@end

@implementation ABScreenCaptureController

- (id)init
{
    if (self = [super init]) {
        self.capture = [[ABScreenCapture alloc] init];
    }
    return self;
}

#pragma mark - Public

- (void)takeScreenshot
{
    NSImage *screenshot = [self.capture captureMainDisplay];
    [self startFlashWindowAnimation];
    NSLog(@"Screenshot taken: %@", screenshot);
}

- (void)captureArea
{
    NSLog(@"Capture area!");
}

#pragma mark - Private

- (void)startFlashWindowAnimation
{
    NSScreen *screen = [NSScreen screens][0];
    self.flashWindow = [[NSWindow alloc] initWithContentRect:screen.frame
                                              styleMask:NSBorderlessWindowMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO
                                                 screen:screen];
    self.flashWindow.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.flashWindow.level = CGShieldingWindowLevel();
    self.flashWindow.alphaValue = 1.0;
    self.flashWindow.ignoresMouseEvents = NO;
    [self.flashWindow setOpaque:NO];
    [self.flashWindow setReleasedWhenClosed:NO];
    [self.flashWindow makeKeyAndOrderFront:nil];
    
    NSDictionary *fadeAnimation = @{NSViewAnimationTargetKey : self.flashWindow,
                                    NSViewAnimationEffectKey : NSViewAnimationFadeOutEffect};
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[fadeAnimation]];
    animation.duration = 1.0;
    animation.delegate = self;
    [animation startAnimation];
}

#pragma mark - Protocol conformance
#pragma mark NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.flashWindow close];
}

@end
