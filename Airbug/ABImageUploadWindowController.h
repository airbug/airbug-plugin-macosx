//
//  ABImageUploadWindowController.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABImageUploadWindowControllerDelegate.h"
#import "ABAirbugManager.h"

@interface ABImageUploadWindowController : NSWindowController <NSWindowDelegate>

// Designated initializer
- (id)initWithManager:(ABAirbugManager *)manager;

/**
 The image to upload
 */
@property (strong, nonatomic) NSImage *image;

/**
 The object that manages all interaction with airbug services.
 */
@property (strong, nonatomic) ABAirbugManager *manager;

/**
 The optional delegate for this window controller
 */
@property (weak, nonatomic) id <ABImageUploadWindowControllerDelegate> delegate;

@end