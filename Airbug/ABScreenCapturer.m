//
//  ABScreenCapturer.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABScreenCapturer.h"

@implementation ABScreenCapturer

- (NSImage *)captureMainDisplay
{
    CGImageRef image = CGDisplayCreateImage(kCGDirectMainDisplay);
    NSImage *screenshot = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
    CGImageRelease(image);
    
    return screenshot;
}

@end
