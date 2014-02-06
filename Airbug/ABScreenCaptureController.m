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
@property (strong, nonatomic) NSWindow *flashWindow;
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
    //[self startFlashWindowAnimation];
    NSLog(@"Screenshot taken: %@", screenshot);
    
    // TODO: Let user mouse over to chosen display?
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSArray *screens = [NSScreen screens];
    for (NSScreen *screen in screens) {
        if (NSMouseInRect(mouseLoc, screen.frame, NO)) {
            NSLog(@"Current screen the mouse is in: %@", screen.deviceDescription[@"NSScreenNumber"]);
        }
    }
    
    // TODO: Upload screenshot?
    [self.delegate didTakeScreenshot:screenshot];
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
    animation.duration = 1.5;
    animation.animationCurve = NSAnimationEaseInOut;
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
