//
//  ABAppDelegate.h
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABCaptureManager.h"
#import "ABUploadWindowController.h"

@interface ABAppDelegate : NSObject <NSApplicationDelegate, ABCaptureManagerDelegate, ABUploadWindowControllerDelegate>

@end
