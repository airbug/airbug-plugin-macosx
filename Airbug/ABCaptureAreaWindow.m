//
//  ABCaptureAreaWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureAreaWindow.h"
#import "ABCaptureAreaView.h"

@implementation ABCaptureAreaWindow

NSString * const ABCaptureAreaWindowDidCaptureAreaNotification = @"ABCaptureAreaWindowDidCaptureArea";

#pragma mark - Lifecycle

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:NSBackingStoreBuffered
                                defer:NO
                               screen:screen];
    if (self) {
        [self setUp];
        [self subscribeToNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)cancelOperation:(id)sender
{
    [self close];
}

// If we do not override this, window cannot become first responder and can't receive cancelOperation:.
- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

// Commenting this out -- not necessary to support cancelOperation:
//- (BOOL)canBecomeMainWindow {
//    return YES;
//}

#pragma mark - Private

- (void)setUp
{
    self.backgroundColor = [NSColor clearColor];
    int windowLevel = CGShieldingWindowLevel();
    [self setLevel:windowLevel];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setIgnoresMouseEvents:NO];
    
    ABCaptureAreaView *captureAreaView = [[ABCaptureAreaView alloc] initWithFrame:NSZeroRect];
    captureAreaView.delegate = self;
    [self setContentView:captureAreaView];
    
//    NSViewAnimation *animation = [NSViewAnimation 
}

- (void)subscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignMainNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:self];
}

// Lost window focus, so go away!
- (void)windowDidResignKey:(NSNotification *)notification
{
    [self close];
}

#pragma mark - Protocol conformance
#pragma mark ABCaptureAreaViewDelegate

- (void)didCaptureArea:(NSRect)rect
{
    [self close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ABCaptureAreaWindowDidCaptureAreaNotification object:[NSValue valueWithRect:rect]];
}

@end
