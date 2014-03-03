//
//  ABVideoScreenCapture.h
//  Airbug
//
//  Created by Richard Shin on 3/1/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ABVideoScreenCapturer : NSObject <AVCaptureFileOutputRecordingDelegate>

- (void)startCapturingForScreen:(NSScreen *)screen toOutputFile:(NSURL *)destPath sessionPreset:(NSString *)sessionPreset maxTime:(NSUInteger)maxTime onCompletion:(void (^)(NSURL *outputFile, NSError *error))completionHandler;

- (void)stopCapturing;

@end
