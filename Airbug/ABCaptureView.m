//
//  ABCaptureView.m
//  Airbug
//
//  Created by Richard Shin on 2/10/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureView.h"

@implementation ABCaptureView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
	
    NSColor *fillColor = [NSColor colorWithCalibratedRed:0.0
                                                   green:0.0
                                                    blue:0.0
                                                   alpha:0.5];
    [fillColor setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
    [path fill];
}

@end
