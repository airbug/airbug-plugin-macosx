//
//  NSImage+Data.m
//  Airbug
//
//  Created by Richard Shin on 2/11/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "NSImage+Data.h"

@implementation NSImage (Data)

- (NSData *)PNGRepresentation
{
    [self lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, self.size.width, self.size.height)];
    [self unlockFocus];
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:nil];
}

@end
