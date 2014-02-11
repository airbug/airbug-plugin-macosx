//
//  ABCaptureAreaWindow.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureWindow.h"
#import "ABCaptureAreaView.h"

@interface ABCaptureWindow ()
@property (strong, nonatomic) NSTextField *instructionsTextField;
@end

@implementation ABCaptureWindow

NSString * const ABCaptureWindowDidCaptureNotification = @"ABCaptureWindowDidCaptureNotification";
NSString * const ABCaptureWindowScreenKey = @"ABCaptureWindowScreenKey";
NSString * const ABCaptureWindowRectKey = @"ABCaptureWindowRectKey";

#pragma mark - Lifecycle

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:screen];
    if (self) {
        [self subscribeToWindowFocusNotifications];
        self.acceptsMouseMovedEvents = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma Custom accessors

- (void)setInstructions:(NSAttributedString *)instructions
{
    _instructions = instructions;
    if (!self.instructionsTextField) {
        self.instructionsTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [self.instructionsTextField setEditable:NO];
        [self.instructionsTextField setSelectable:NO];
        [self.instructionsTextField setBordered:NO];
        [self.instructionsTextField setDrawsBackground:NO];
        [self.instructionsTextField setAlphaValue:1.0];
        [self.contentView addSubview:self.instructionsTextField positioned:NSWindowAbove relativeTo:nil];
    }
    [self.instructionsTextField setAttributedStringValue:self.instructions];
    [self.instructionsTextField sizeToFit];
    [self repositionInstructions];
}

#pragma mark - Public

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [super setFrame:frameRect display:flag];
    
    [self repositionInstructions];
}

- (void)cancelOperation:(id)sender {
    [self close];
}

// If we do not override this, window cannot become first responder and can't receive cancelOperation:.
- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.instructionsTextField setAlphaValue:0.0];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    
    // Check if user has moved mouse to different screen, and reposition if necessary
    NSPoint mouseLoc = [NSEvent mouseLocation];
    if (NSMouseInRect(mouseLoc, self.screen.frame, NO)) {
        return;
    }
    
    NSArray *screens = [NSScreen screens];
    NSScreen *screenWithCursor;
    for (NSScreen *screen in screens) {
        if (NSMouseInRect(mouseLoc, screen.frame, NO)) {
            screenWithCursor = screen;
            break;
        }
    }
    [self setFrame:screenWithCursor.frame display:YES];
    [self repositionInstructions];
}

#pragma mark - Private

// We subscribe to these notifications so that if capture window loses focus, it closes itself.
- (void)subscribeToWindowFocusNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignMainNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:self];
}

- (void)repositionInstructions
{
    NSSize size = self.instructionsTextField.frame.size;
    CGFloat originX = (self.frame.size.width / 2.0) - (size.width / 2.0);
    CGFloat originY = (1.0/5.0) * self.frame.size.height;
    self.instructionsTextField.frame = NSMakeRect(originX, originY, size.width, size.height);
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [self close];
}

@end
