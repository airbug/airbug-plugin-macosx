//
//  ABUploadWindowController.h
//  Airbug
//
//  Created by Richard Shin on 3/2/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugManager.h"

@class ABUploadWindowController;

@protocol ABUploadWindowControllerDelegate <NSObject>

- (void)uploadWindowControllerWillClose:(ABUploadWindowController *)controller;

@end

@interface ABUploadWindowController : NSWindowController

/**
 Designated initializer.
 @param manager The @c ABAirbugManager to use to upload files
 */
- (id)initWithManager:(ABAirbugManager *)manager;

/**
 Abstract method that must be overridden by subclasses
 */
- (void)startUpload;

/**
 The object that manages all interaction with airbug services.
 */
@property (strong, nonatomic) ABAirbugManager *manager;

/**
 The optional delegate for this window controller
 */
@property (weak, nonatomic) id <ABUploadWindowControllerDelegate> delegate;

/**
 Completion handler to fire when upload completes. Set to read-only so that subclasses can execute it.
 */
@property (strong, readonly, nonatomic) void(^completionHandler)(NSURL *uploadURL, NSError *error);

@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *uploadButton;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;

@end
