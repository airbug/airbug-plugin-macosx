//
//  ABScreenCaptureController.h
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABScreenCapture.h"

@protocol ABScreenCaptureControllerDelegate <NSObject>
- (void)didTakeScreenshot:(NSImage *)image;
- (void)didCaptureArea:(NSImage *)image;
@end

@interface ABScreenCaptureController : NSObject <NSAnimationDelegate>

- (void)takeScreenshot;
- (void)captureArea;

@property (weak, nonatomic) id <ABScreenCaptureControllerDelegate> delegate;
@property (strong, nonatomic) ABScreenCapture *capturer;

@end
