//
//  ABTargetedScreenshotWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/10/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABTargetedScreenshotWindow.h"

@interface ABTargetedScreenshotWindow ()
@property (strong, nonatomic) ABCaptureAreaView *captureAreaView;
@end

@implementation ABTargetedScreenshotWindow

#pragma mark - Lifecycle

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:screen];
    if (self) {
        [self setUp];
    }
    
    return self;
}

#pragma mark - Public

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [self.captureAreaView setFrame:NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height)];
    [super setFrame:frameRect display:flag];
}

#pragma mark - Private

- (void)setUp
{
    // Set this up to be a full-screen, shielding, clear window
    int windowLevel = CGShieldingWindowLevel();
    [self setLevel:windowLevel];
    self.backgroundColor = [NSColor clearColor];
    [self setOpaque:NO];
    
    // Add capture overlay view
    self.captureAreaView = [[ABCaptureAreaView alloc] initWithFrame:NSZeroRect];
    self.captureAreaView.delegate = self;
    [self setContentView:self.captureAreaView];
}

#pragma mark - Protocol conformance
#pragma mark ABCaptureAreaViewDelegate

- (void)didCaptureArea:(NSRect)rect
{
    [self close];
    NSDictionary *captureDictionary = @{ABCaptureWindowRectKey : [NSValue valueWithRect:rect],
                                        ABCaptureWindowScreenKey : self.screen};
    [[NSNotificationCenter defaultCenter] postNotificationName:ABCaptureWindowDidCaptureNotification
                                                        object:captureDictionary];
}

@end
