//
//  ABImageUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABImageUploadWindowController.h"

@interface ABImageUploadWindowController ()
@property (weak) IBOutlet NSImageView *imageView;

@end

@implementation ABImageUploadWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.imageView.image = self.image;
}

#pragma mark - Custom accessors

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
}

#pragma mark - Protocol conformance
#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [self.delegate imageUploadControllerWillClose:self];
}

@end
