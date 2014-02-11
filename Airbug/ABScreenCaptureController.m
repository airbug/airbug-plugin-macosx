//
//  ABScreenCaptureController.m
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCaptureController.h"
#import "ABScreenCapture.h"
#import "ABScreenshotWindow.h"
#import "ABTargetedScreenshotWindow.h"
#import "NSImage+Crop.h"

@interface ABScreenCaptureController ()
@property (strong, nonatomic) NSWindow *flashWindow;
@property (strong, nonatomic) ABCaptureWindow *captureWindow;
@end

@implementation ABScreenCaptureController

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        self.capturer = [[ABScreenCapture alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tookScreenshot:)
                                                     name:ABCaptureWindowDidCaptureNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom accessors

- (void)setDelegate:(id<ABScreenCaptureControllerDelegate>)delegate
{
    if (![delegate conformsToProtocol:@protocol(ABScreenCaptureControllerDelegate)]) {
        [NSException raise:@"Nonconforming delegate" format:@"Delegate must conform to ABScreenCaptureControllerDelegate protocol"];
    }
    _delegate = delegate;
}

#pragma mark - Public

- (void)takeScreenshot {
    [self displayScreenshotWindow];
}

- (void)captureArea {
    [self displayTargetedScreenshotWindow];
}

#pragma mark - Private

- (void)displayScreenshotWindow
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    self.captureWindow = [[ABScreenshotWindow alloc] initWithContentRect:mainScreen.frame
                                                                  styleMask:NSBorderlessWindowMask
                                                                    backing:NSBackingStoreBuffered
                                                                      defer:NO
                                                                     screen:mainScreen];
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString:@"Click to capture screenshot, ESC to cancel" attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
    self.captureWindow.instructions = instructions;
    [self displayWindow];
}

- (void)displayTargetedScreenshotWindow
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    self.captureWindow = [[ABTargetedScreenshotWindow alloc] initWithContentRect:mainScreen.frame
                                                                    styleMask:NSBorderlessWindowMask
                                                                      backing:NSBackingStoreBuffered
                                                                        defer:NO
                                                                       screen:mainScreen];
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString:@"Drag to capture area, ESC to cancel" attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
    self.captureWindow.instructions = instructions;
    [self displayWindow];
}

- (void)displayWindow
{
    // TODO: Is this necessary?
    [self.captureWindow setReleasedWhenClosed:NO];
    [self.captureWindow makeKeyAndOrderFront:nil];
    [self.captureWindow makeFirstResponder:nil];
}

- (void)tookScreenshot:(NSNotification *)notification
{
    [self.captureWindow close];
    
    NSDictionary *captureDictionary = (NSDictionary *)notification.object;
    NSRect captureRect = [captureDictionary[ABCaptureWindowRectKey] rectValue];
    NSScreen *captureScreen = captureDictionary[ABCaptureWindowScreenKey];
    NSImage *captureImage = [self.capturer captureScreen:captureScreen];

    // Check if capture rect requires us to crop the image
    if (!NSEqualSizes(captureRect.size, captureScreen.frame.size)) {
        captureImage = [captureImage cropToRect:captureRect];
    }
    
    [self startFlashAnimationOnScreen:captureScreen];
    [self.delegate didCaptureArea:captureImage];
}

- (void)startFlashAnimationOnScreen:(NSScreen *)screen
{
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
    animation.animationCurve = NSAnimationEaseInOut;
    animation.delegate = self;
    [animation startAnimation];
}

#pragma mark - Protocol conformance
#pragma mark NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.flashWindow close];
    self.flashWindow = nil;
}

@end
