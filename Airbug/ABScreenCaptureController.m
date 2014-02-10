//
//  ABScreenCaptureController.m
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCaptureController.h"
#import "ABScreenCapture.h"
#import "ABCaptureAreaWindow.h"
#import "NSImage+Crop.h"

@interface ABScreenCaptureController ()
@property (strong, nonatomic) NSWindow *flashWindow;
@property (strong, nonatomic) ABCaptureAreaWindow *areaCaptureWindow;
@end

@implementation ABScreenCaptureController

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        self.capturer = [[ABScreenCapture alloc] init];
    }
    return self;
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

- (void)takeScreenshot
{
    NSImage *screenshot = [self.capturer captureMainScreen];
    [self startFlashWindowAnimation];
    
    // TODO: Upload screenshot?
    [self.delegate didTakeScreenshot:screenshot];
}

- (void)captureArea
{    
    [self displayOverlayOnMainDisplay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(capturedArea:)
                                                 name:ABCaptureAreaWindowDidCaptureAreaNotification
                                               object:nil];
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
    animation.animationCurve = NSAnimationEaseInOut;
    animation.delegate = self;
    [animation startAnimation];
}

- (void)displayOverlayOnMainDisplay
{
    NSScreen *screen = [NSScreen screens][0];
    self.areaCaptureWindow = [[ABCaptureAreaWindow alloc] initWithContentRect:screen.frame
                                                                    styleMask:NSBorderlessWindowMask
                                                                      backing:NSBackingStoreBuffered
                                                                        defer:NO
                                                                       screen:screen];
    [self.areaCaptureWindow setReleasedWhenClosed:NO];
    [self.areaCaptureWindow makeKeyAndOrderFront:nil];
    [self.areaCaptureWindow makeFirstResponder:nil];
}

- (void)capturedArea:(NSNotification *)notification
{
    NSDictionary *captureDictionary = (NSDictionary *)notification.object;
    NSRect captureRect = [captureDictionary[ABCaptureAreaWindowRectKey] rectValue];
    NSScreen *captureScreen = captureDictionary[ABCaptureAreaWindowScreenKey];
    NSImage *captureImage = [self.capturer captureScreen:captureScreen];
    NSImage *croppedImage = [captureImage cropToRect:captureRect];
    [self.delegate didCaptureArea:croppedImage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ABCaptureAreaWindowDidCaptureAreaNotification object:nil];
}

#pragma mark - Protocol conformance
#pragma mark NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.flashWindow close];
    self.flashWindow = nil;
}

@end
