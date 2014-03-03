//
//  ABImageUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABImageUploadWindowController.h"
#import "NSImage+Data.h"

@interface ABImageUploadWindowController ()
@property (weak) IBOutlet NSImageView *imageView;
@end

@implementation ABImageUploadWindowController

#pragma mark - Lifecycle

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.imageView.image = self.image;
}

#pragma mark - Custom accessors

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
}

#pragma mark - Public

- (NSString *)windowNibName {
    return @"ABImageUploadWindow";
}

- (void)startUpload
{
    NSData *imageData = [self.image PNGRepresentation];
    [self.manager uploadPNGImageData:imageData onCompletion:self.completionHandler];
}

@end
