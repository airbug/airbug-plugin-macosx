//
//  ABScreenVideoCaptureWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/28/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABVideoScreenCaptureWindow.h"
#import "ABCaptureView.h"

@interface ABVideoScreenCaptureWindow ()
@property (strong, nonatomic) ABCaptureView *overlayView;
@property (nonatomic) BOOL isRecording;
@end

@implementation ABVideoScreenCaptureWindow

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

#pragma mark NSWindow

- (void)windowDidResignMain:(NSNotification *)notification
{
    [self setLevel:NSStatusWindowLevel];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [self.overlayView setFrame:NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height)];
    [super setFrame:frameRect display:flag];
}

#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    // We want to allow window to move to different screens ONLY if recording hasn't started yet.
    if (self.isRecording) return;
    [super mouseMoved:theEvent];
}

#pragma mark - Private

- (void)setUp
{
    self.level = NSStatusWindowLevel;
}

@end
