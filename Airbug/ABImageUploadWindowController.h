//
//  ABImageUploadWindowController.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABImageUploadWindowControllerDelegate.h"

@interface ABImageUploadWindowController : NSWindowController <NSWindowDelegate>

// Designated initializer
- (id)init;

/**
 The image to upload
 */
@property (strong, nonatomic) NSImage *image;

/**
 The optional delegate for this window controller
 */
@property (weak, nonatomic) id <ABImageUploadWindowControllerDelegate> delegate;

@end