//
//  ABVideoScreenCapture.m
//  Airbug
//
//  Created by Richard Shin on 3/1/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABVideoScreenCapturer.h"

@interface ABVideoScreenCapturer ()
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) NSTimer *timer;
@property (copy, nonatomic) void (^completionHandler)(NSURL *, NSError *);
@end

@implementation ABVideoScreenCapturer

#pragma mark - Public methods

- (void)startCapturingForScreen:(NSScreen *)screen toOutputFile:(NSURL *)destPath sessionPreset:(NSString *)sessionPreset maxTime:(NSUInteger)maxTime onCompletion:(void (^)(NSURL *outputFile, NSError *error))completionHandler;
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = sessionPreset;
    
    CGDirectDisplayID screenID = (CGDirectDisplayID)[screen.deviceDescription[@"NSScreenNumber"] integerValue];
    AVCaptureScreenInput *input = [[AVCaptureScreenInput alloc] initWithDisplayID:screenID];
    if (!input) {
        self.session = nil;
        return;
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:self.movieFileOutput]) {
        [self.session addOutput:self.movieFileOutput];
    }
    
    [self.session startRunning];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[destPath path]])
    {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:[destPath path] error:&error]) {
            completionHandler(nil, error);
        }
    }
    
    [self.movieFileOutput startRecordingToOutputFileURL:destPath recordingDelegate:self];
    if (maxTime > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)maxTime target:self selector:@selector(maxTimeReached:) userInfo:nil repeats:NO];
    }
    
    self.completionHandler = completionHandler;
    NSLog(@"Started capturing to %@", destPath);
}

- (void)stopCapturing
{
    NSLog(@"Stopping...");
    [self.timer invalidate];
    self.timer = nil;
    if (self.movieFileOutput.isRecording) {
        [self.movieFileOutput stopRecording];
    }
}

-(void)maxTimeReached:(NSTimer *)timer
{
    NSLog(@"Max recording time reached");
    [self stopCapturing];
}

#pragma mark - Protocol conformance
#pragma mark AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"Did finish recording to %@. Error: %@", [outputFileURL description], [error description]);
    
    [self.session stopRunning];
    self.session = nil;
    
    if (self.completionHandler) {
        self.completionHandler(outputFileURL, error);
    }
    self.completionHandler = nil;
}


@end
