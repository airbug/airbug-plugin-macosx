//
//  ABCaptureManager.h
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABScreenCapturer.h"
#import "ABVideoScreenCapturer.h"

@protocol ABCaptureManagerDelegate <NSObject>
- (void)didCaptureImage:(NSImage *)image;
- (void)didCaptureFile:(NSURL *)file;
@end

@interface ABCaptureManager : NSObject <NSAnimationDelegate>

- (void)captureScreenshot;
- (void)captureTargetedScreenshot;
- (void)startVideoScreenCapture;
- (void)stopVideoScreenCapture;

@property (weak, nonatomic) id <ABCaptureManagerDelegate> delegate;
@property (strong, nonatomic) ABScreenCapturer *capturer;
@property (strong, nonatomic) ABVideoScreenCapturer *videoCapturer;

@end
