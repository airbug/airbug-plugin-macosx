//
//  ABImageUploadWindowController.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABUploadWindowController.h"

@interface ABImageUploadWindowController : ABUploadWindowController <NSWindowDelegate>

/**
 The image to upload
 */
@property (strong, nonatomic) NSImage *image;

@end