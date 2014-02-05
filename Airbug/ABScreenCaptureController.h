//
//  ABScreenCaptureController.h
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ABScreenCaptureController : NSWindow <NSAnimationDelegate>

- (void)takeScreenshot;
- (void)captureArea;

@end
