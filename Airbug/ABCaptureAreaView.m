//
//  ABCaptureAreaView.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureAreaView.h"

@interface ABCaptureAreaView ()
@property (nonatomic) CGRect captureRect;
@end

@implementation ABCaptureAreaView

#pragma mark - Lifecycle

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

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
    CGPoint pointInView = [theEvent locationInWindow];
    
    // Click point inside rect, so capture!
    if (CGRectContainsPoint(self.captureRect, pointInView)) {
        NSLog(@"Capturing area!");
    }
    
    // Click point not inside rect, so make new capture rect
    self.captureRect = CGRectMake(pointInView.x, pointInView.y, 0.0, 0.0);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGPoint pointInView = [theEvent locationInWindow];
    self.captureRect = CGRectMake(self.captureRect.origin.x, self.captureRect.origin.y, pointInView.x - self.captureRect.origin.x, pointInView.y - self.captureRect.origin.y);
    
#ifdef DEBUG
    [self setNeedsDisplay:YES];
#endif
}

// TODO: How to handle when mouse moves out of screen...?

@end
