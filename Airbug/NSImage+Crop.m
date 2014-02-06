//
//  NSImage+Crop.m
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "NSImage+Crop.h"

@implementation NSImage (Crop)

- (NSImage *)cropToRect:(NSRect)rect
{
    NSImage *croppedImage = [[NSImage alloc] initWithSize:rect.size];
    [croppedImage lockFocus];
    NSRect croppedImageBounds = NSMakeRect(0.0, 0.0, rect.size.width, rect.size.height);
    [self drawInRect:croppedImageBounds fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [croppedImage unlockFocus];
    return croppedImage;
}

@end
