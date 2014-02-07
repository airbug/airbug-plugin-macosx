//
//  ABImageUploadWindowControllerDelegate.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ABImageUploadWindowController;

@protocol ABImageUploadWindowControllerDelegate <NSObject>

- (void)imageUploadControllerWillClose:(ABImageUploadWindowController *)controller;

@end
