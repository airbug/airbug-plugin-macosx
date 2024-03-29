//
//  ABAppDelegate.h
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABAirbugManager.h"
#import "ABCaptureManager.h"
#import "ABUploadWindowController.h"

@interface ABAppDelegate : NSObject <NSApplicationDelegate, ABCaptureManagerDelegate, ABAirbugManagerDelegate>

@end
