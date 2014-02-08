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

- (void)mouseDown:(NSEvent *)theEvent
{
    [self.instructionsTextField setAlphaValue:0.0];
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
    ABCaptureAreaView *captureAreaView = [[ABCaptureAreaView alloc] initWithFrame:NSZeroRect];
    captureAreaView.delegate = self;
    [self setContentView:captureAreaView];
    
    // Add "instructions" view
    NSDictionary *attributes = @{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0],
                                 NSForegroundColorAttributeName : [NSColor whiteColor]};
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString: @"Click and drag to capture, ESC to cancel" attributes:attributes];
    self.instructionsTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [self.instructionsTextField setEditable:NO];
    [self.instructionsTextField setSelectable:NO];
    [self.instructionsTextField setBordered:NO];
    [self.instructionsTextField setDrawsBackground:NO];
    [self.instructionsTextField setAttributedStringValue:instructions];
    [self.instructionsTextField setAlphaValue:0.7];
    [self.instructionsTextField sizeToFit];
    NSSize size = self.instructionsTextField.frame.size;
    CGFloat originX = (self.frame.size.width / 2.0) - (size.width / 2.0);
    CGFloat originY = (1.0/5.0) * self.frame.size.height;
    self.instructionsTextField.frame = NSMakeRect(originX, originY, size.width, size.height);
    [captureAreaView addSubview:self.instructionsTextField];
}

// We subscribe to these notifications so that if capture window loses focus, it closes itself.
- (void)subscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignMainNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:self];
}

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
