//
//  ABCaptureAreaWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureAreaWindow.h"
#import "ABCaptureAreaView.h"

@interface ABCaptureAreaWindow ()
@property (strong, nonatomic) NSTextField *instructionsTextField;
@end

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

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.instructionsTextField setAlphaValue:0.0];
}

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
    
    NSDictionary *attributes = @{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0],
                                 NSForegroundColorAttributeName : [NSColor whiteColor]};
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString: @"Click and drag to capture, ESC to cancel" attributes:attributes];
    
    self.instructionsTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(400, 400, 500, 500)];
    [self.instructionsTextField setEditable:NO];
    [self.instructionsTextField setSelectable:NO];
    [self.instructionsTextField setBordered:NO];
    [self.instructionsTextField setDrawsBackground:NO];
    [self.instructionsTextField setAttributedStringValue:instructions];
    [self.instructionsTextField sizeToFit];
    [self.instructionsTextField setAlphaValue:0.5];
    [captureAreaView addSubview:self.instructionsTextField];
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
