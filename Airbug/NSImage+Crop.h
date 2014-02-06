//
//  NSImage+Crop.h
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Crop)

- (NSImage *)cropToRect:(NSRect)rect;

@end
