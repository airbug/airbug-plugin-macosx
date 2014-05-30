//
//  ABCaptureManager.m
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABCaptureManager.h"
#import "ABScreenshotWindow.h"
#import "ABTargetedScreenshotWindow.h"
#import "ABVideoScreenCaptureWindow.h"
#import "NSImage+Crop.h"

@interface ABCaptureManager ()
@property (strong, nonatomic) NSWindow *flashWindow;
@property (strong, nonatomic) ABCaptureWindow *captureWindow;
@end

@implementation ABCaptureManager

#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        _capturer = [[ABScreenCapturer alloc] init];
        _videoCapturer = [[ABVideoScreenCapturer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tookScreenshot:)
                                                     name:ABCaptureWindowDidCaptureNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom accessors

- (void)setDelegate:(id<ABCaptureManagerDelegate>)delegate
{
    if (![delegate conformsToProtocol:@protocol(ABCaptureManagerDelegate)]) {
        [NSException raise:@"Nonconforming delegate" format:@"Delegate must conform to ABScreenCaptureControllerDelegate protocol"];
    }
    _delegate = delegate;
}

#pragma mark - Public

- (void)captureScreenshot {
    [self displayScreenshotWindow];
}

- (void)captureTargetedScreenshot {
    [self displayTargetedScreenshotWindow];
}

- (void)captureTimedScreenshot {
    [self displayTimedScreenshotWindow];
}

- (void)startVideoScreenCapture {
    NSLog(@"ABCaptureManager - start video screen capture");
    [self displayVideoScreenCaptureWindow];
    NSURL *destPath = [self URLForVideoCaptureFile];
    [self.videoCapturer startCapturingForScreen:[NSScreen mainScreen] toOutputFile:destPath sessionPreset:AVCaptureSessionPresetHigh maxTime:30 onCompletion:^(NSURL *outputFile, NSError *error) {
        if (error) {
            NSLog(@"Error capturing screen video: %@", [error localizedDescription]);
        } else {
            [self.delegate didCaptureFile:outputFile];
        }
    }];
}

- (void)stopVideoScreenCapture {
    NSLog(@"ABCaptureManager - stop video screen capture");
    [self.videoCapturer stopCapturing];
}

#pragma mark - Private

- (void)displayScreenshotWindow
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    self.captureWindow = [[ABScreenshotWindow alloc] initWithContentRect:mainScreen.frame
                                                                  styleMask:NSBorderlessWindowMask
                                                                    backing:NSBackingStoreBuffered
                                                                      defer:NO
                                                                     screen:mainScreen];
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString:@"Click to capture screenshot, ESC to cancel" attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
    self.captureWindow.instructions = instructions;
    [self displayCaptureWindow:self.captureWindow];
}

- (void)displayTargetedScreenshotWindow
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    self.captureWindow = [[ABTargetedScreenshotWindow alloc] initWithContentRect:mainScreen.frame
                                                                    styleMask:NSBorderlessWindowMask
                                                                      backing:NSBackingStoreBuffered
                                                                        defer:NO
                                                                       screen:mainScreen];
    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString:@"Drag to capture area, ESC to cancel" attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
    self.captureWindow.instructions = instructions;
    [self displayCaptureWindow:self.captureWindow];
}

- (void)displayTimedScreenshotWindow
{
// TODO: create a timed screenshot window that counts down before capturing a screen!
    
//    NSScreen *mainScreen = [NSScreen mainScreen];
//    self.captureWindow = [[ABTargetedScreenshotWindow alloc] initWithContentRect:mainScreen.frame
//                                                                       styleMask:NSBorderlessWindowMask
//                                                                         backing:NSBackingStoreBuffered
//                                                                           defer:NO
//                                                                          screen:mainScreen];
//    NSAttributedString *instructions = [[NSAttributedString alloc] initWithString:@"Drag to capture area, ESC to cancel" attributes:@{NSFontAttributeName : [NSFont boldSystemFontOfSize:48.0], NSForegroundColorAttributeName : [NSColor whiteColor]}];
//    self.captureWindow.instructions = instructions;
//    [self displayCaptureWindow:self.captureWindow];
}

- (void)displayVideoScreenCaptureWindow
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    self.captureWindow = [[ABVideoScreenCaptureWindow alloc] initWithContentRect:mainScreen.frame
                                                                       styleMask:NSBorderlessWindowMask
                                                                         backing:NSBackingStoreBuffered
                                                                           defer:NO
                                                                          screen:mainScreen];
    [self displayCaptureWindow:self.captureWindow];
}

- (void)displayCaptureWindow:(ABCaptureWindow *)captureWindow
{
    // Necessary to steal focus from other applications, otherwise taking a screenshot requires
    // one mouse click to bring the capture window into focus, and another mouse click to start the
    // actual capture process.
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    // Necessary, otherwise accessing the window a second time causes a crash.
    [captureWindow setReleasedWhenClosed:NO];
    [captureWindow makeKeyAndOrderFront:nil];
    [captureWindow makeFirstResponder:nil];
}

- (void)tookScreenshot:(NSNotification *)notification
{
    [self.captureWindow close];
    
    NSDictionary *captureDictionary = (NSDictionary *)notification.object;
    NSRect captureRect = [captureDictionary[ABCaptureWindowRectKey] rectValue];
    NSScreen *captureScreen = captureDictionary[ABCaptureWindowScreenKey];
    NSImage *captureImage = [self.capturer captureScreen:captureScreen];

    // Check if capture rect requires us to crop the image
    if (!NSEqualSizes(captureRect.size, captureScreen.frame.size)) {
        captureImage = [captureImage cropToRect:captureRect];
    }
    
    [self startFlashAnimationOnScreen:captureScreen];
    [self.delegate didCaptureImage:captureImage];
}

- (void)startFlashAnimationOnScreen:(NSScreen *)screen
{
    self.flashWindow = [[NSWindow alloc] initWithContentRect:screen.frame
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:screen];
    self.flashWindow.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.flashWindow.level = CGShieldingWindowLevel();
    self.flashWindow.alphaValue = 1.0;
    self.flashWindow.ignoresMouseEvents = NO;
    [self.flashWindow setOpaque:NO];
    [self.flashWindow setReleasedWhenClosed:NO];
    [self.flashWindow makeKeyAndOrderFront:nil];
    
    NSDictionary *fadeAnimation = @{NSViewAnimationTargetKey : self.flashWindow,
                                    NSViewAnimationEffectKey : NSViewAnimationFadeOutEffect};
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[fadeAnimation]];
    animation.duration = 1.0;
    animation.animationCurve = NSAnimationEaseInOut;
    animation.delegate = self;
    [animation startAnimation];
}

- (NSURL *)URLForVideoCaptureFile
{
    NSString *filename = [NSString stringWithFormat:@"airbug Screen Capture %@.mov", [NSDate date]];
    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemp(tempFileNameCString);
    
    if (fileDescriptor == -1) {
        NSLog(@"Failed to create file descriptor");
        return nil;
    }
    
    // This is the file name if you need to access the file by name, otherwise you can remove
    // this line.
    NSString *tempFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString
     length:strlen(tempFileNameCString)];
    
    free(tempFileNameCString);
    
    return [NSURL fileURLWithPath:tempFileName];
}

#pragma mark - Protocol conformance
#pragma mark NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation
{
    [self.flashWindow close];
    self.flashWindow = nil;
}

@end
