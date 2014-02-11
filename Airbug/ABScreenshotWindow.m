//
//  ABScreenshotWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/10/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenshotWindow.h"
#import "ABScreenCapture.h"
#import "ABCaptureView.h"

@interface ABScreenshotWindow ()
@property (strong, nonatomic) ABCaptureView *overlayView;
@end

@implementation ABScreenshotWindow

#pragma mark - Lifecycle

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - Public

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [self.overlayView setFrame:NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height)];
    [super setFrame:frameRect display:flag];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self sendNotification];
    [super mouseDown:theEvent];
}

#pragma mark - Private

- (void)setUp
{
    // Set this up to be a full-screen, shielding, clear window
    int windowLevel = CGShieldingWindowLevel();
    [self setLevel:windowLevel];
    self.backgroundColor = [NSColor clearColor];
    [self setOpaque:NO];
    
    self.overlayView = [[ABCaptureView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.contentView addSubview:self.overlayView];
}

- (void)sendNotification
{
    NSDictionary *captureDictionary = @{ABCaptureWindowScreenKey : self.screen, ABCaptureWindowRectKey : [NSValue valueWithRect:self.screen.frame]};
    [[NSNotificationCenter defaultCenter] postNotificationName:ABCaptureWindowDidCaptureNotification object:captureDictionary];
}

@end
