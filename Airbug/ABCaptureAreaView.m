//
//  ABCaptureAreaView.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureAreaView.h"

@interface ABCaptureAreaView ()
@property (nonatomic) NSRect captureRect;
@end

@implementation ABCaptureAreaView

// To keep track of the capture rect's state (started, changed, ended, not started), I've chosen an uninitialized
// capture rect to be at origin (-1.0, -1.0). This knowledge is used in startedCaptureRect:.
#define UNINITIALIZED_CAPTURE_RECT NSMakeRect(-1.0, -1.0, 0, 0)

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        [self clearCaptureRect];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self clearCaptureRect];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self clearCaptureRect];
    }
    return self;
}

#pragma mark - Public

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw white outline around contentRect
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.captureRect];
    [path setLineWidth:1.0];
    [[NSColor whiteColor] setStroke];
    [path stroke];

    // Fill everything *but* contextRect
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRect:self.bounds];
    [clipPath appendBezierPathWithRect:self.captureRect];
    clipPath.windingRule = NSEvenOddWindingRule;
    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] setFill];
    [clipPath fill];
    
#ifdef DEBUG
    NSString *captureRectString = [NSString stringWithFormat:@"Rect: (%d, %d, %d, %d)", (int)self.captureRect.origin.x, (int)self.captureRect.origin.y, abs((int)self.captureRect.size.width), abs((int)self.captureRect.size.height)];
    NSDictionary *stringAttributes = @{NSFontAttributeName : [NSFont systemFontOfSize:11.0],
                                       NSForegroundColorAttributeName : [NSColor whiteColor]};
    [captureRectString drawAtPoint:CGPointMake(0, 0) withAttributes:stringAttributes];
#endif
}

- (void)resetCursorRects
{
    [self addCursorRect:self.bounds cursor:[NSCursor crosshairCursor]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pointInView = [theEvent locationInWindow];
    [self startCaptureRectAtPoint:pointInView];
    [self setNeedsDisplay:YES];
    
    // Pass the mouseDown: event up the responder chain so that the window has an opportunity to respond
    // to the user drawing a rect (e.g. hiding the instructions).
    [super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([self startedCaptureRect]) {
        NSRect convertedRect = [self convertToNonNegativeRect:self.captureRect];
        if (convertedRect.size.width > 0 && convertedRect.size.height > 0) {
            [self.delegate didCaptureArea:convertedRect];
        } else {
            [self clearCaptureRect];
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    // If the user hits the ESC key while dragging, the capture rect gets cleared. If the user continues to drag,
    // need to make sure that the cleared capture rect doesn't add stuff
    if (![self startedCaptureRect]) return;
    
    NSPoint pointInView = [theEvent locationInWindow];
    [self updateCaptureRectToPoint:pointInView];
    
#ifdef DEBUG
    [self setNeedsDisplay:YES];
#endif
}

- (void)keyDown:(NSEvent *)theEvent
{
    // If a rect is drawing while ESC is pressed, reset the rectangle to zero
    if ([theEvent keyCode] == 53 && [self startedCaptureRect]) {
        [self clearCaptureRect];
        [self setNeedsDisplay:YES];
        return;
    }
    [super keyDown:theEvent];
}

// Must override to receive keyDown: event
- (BOOL)acceptsFirstResponder {
    return YES;
}

#pragma mark - Private

// Convert rect to origin in bottom-left corner so that its width and height are always positive
- (NSRect)convertToNonNegativeRect:(NSRect)rect
{
    if (rect.size.width > 0 && rect.size.height > 0) return rect;

    CGFloat originX = MIN(rect.origin.x, rect.origin.x + rect.size.width);
    CGFloat originY = MIN(rect.origin.y, rect.origin.y + rect.size.height);
    NSRect convertedRect = NSMakeRect(originX, originY, abs(rect.size.width), abs(rect.size.height));
    return convertedRect;
}

- (BOOL)startedCaptureRect {
    return (self.captureRect.origin.x > 0 && self.captureRect.origin.y > 0);
}

-(void)startCaptureRectAtPoint:(NSPoint)point
{
    self.captureRect = NSMakeRect(point.x, point.y, 0, 0);
}

- (void)updateCaptureRectToPoint:(NSPoint)point
{
    NSRect newRect;
    newRect.origin = self.captureRect.origin;
    newRect.size = NSMakeSize(point.x - newRect.origin.x, point.y - newRect.origin.y);
    self.captureRect = newRect;
}

- (void)clearCaptureRect
{
    self.captureRect = UNINITIALIZED_CAPTURE_RECT;
}

// TODO: How to handle when mouse moves out of screen...?

@end
