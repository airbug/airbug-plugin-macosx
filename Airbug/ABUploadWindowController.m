//
//  ABUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 3/2/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABUploadWindowController.h"

@interface ABUploadWindowController ()
@property (nonatomic) id eventMonitor;
@end

@implementation ABUploadWindowController

#pragma mark - Lifecycle

- (id)initWithManager:(ABAirbugManager *)manager
{
    self = [super initWithWindowNibName:[self windowNibName] owner:self];
    if (self) {
        _manager = manager;
        
        __weak typeof(self) weakSelf = self;
        _completionHandler = ^void(NSURL *imageURL, NSError *error)
        {
            if (error) {
                NSLog(@"Error during upload: %@", error);
                [weakSelf updateUIForUploadFailureWithError:error];
            } else {
                [weakSelf updateUIForUploadSuccess:[imageURL absoluteString]];
                [weakSelf launchBrowserToURL:imageURL];
            }
        };
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    static NSPoint cascadeLocation = {20, 20};
    NSPoint nextPoint = [self.window cascadeTopLeftFromPoint:cascadeLocation];
    cascadeLocation = nextPoint;
    
    // To allow ESC button to close window
    self.eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event)
                         {
                             NSWindow *targetWindow = event.window;
                             if (targetWindow != self.window) {
                                 return event;
                             }
                             if (event.keyCode == 53) {
                                 [self.window close];
                                 event = nil;
                             }
                             return event;
                         }];
}

#pragma mark - IBAction

- (IBAction)upload:(NSButton *)sender
{
    [self updateUIForUploadStart];
    [self startUpload];
}

- (void)startUpload
{
    // Abstract
}

- (NSString *)windowNibName
{
    // abstract;
    return nil;
}

#pragma mark - Private

- (void)updateUIForUploadStart
{
    [self.uploadButton setEnabled:NO];
    [self.uploadProgressIndicator startAnimation:nil];
}

- (void)updateUIForUploadFailureWithError:(NSError *)error
{
    [self.uploadButton setEnabled:YES];
    [self.uploadButton setTitle:@"Upload"];
    [self.uploadProgressIndicator stopAnimation:nil];
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

- (void)updateUIForUploadSuccess:(NSString *)url
{
    [self.urlTextField setHidden:NO];
    [self.urlTextField setStringValue:url];
}

- (void)launchBrowserToURL:(NSURL *)url {
    // Upload progress indicator gets stopped here when browser launches (after delay). Better UI feedback for user.
    [self.uploadProgressIndicator performSelector:@selector(stopAnimation:) withObject:nil afterDelay:1.0];
    [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:url afterDelay:2.0];
}

#pragma mark - Protocol conformance
#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [self.delegate uploadWindowControllerWillClose:self];
    [NSEvent removeMonitor:self.eventMonitor];
}

@end
