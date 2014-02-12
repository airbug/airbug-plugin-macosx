//
//  ABImageUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABImageUploadWindowController.h"
#import "NSImage+Data.h"

@interface ABImageUploadWindowController ()
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *uploadButton;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;
@property (weak) IBOutlet NSTextField *uploadProgressTextField;
@property (nonatomic) id eventMonitor;
@end

@implementation ABImageUploadWindowController

- (id)initWithManager:(ABAirbugManager *)manager
{
    self = [super initWithWindowNibName:@"ABImageUploadWindow" owner:self];
    if (self) {
        _manager = manager;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.imageView.image = self.image;
    
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

#pragma mark - Custom accessors

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
}

#pragma mark - IBAction

- (IBAction)upload:(NSButton *)sender
{
    [self updateUIForUploadStart];
    [self startUpload];
}

#pragma mark - Private

- (void)startUpload
{
    NSData *imageData = [self.image PNGRepresentation];
    [self.manager uploadPNGImageData:imageData onCompletion:^(NSURL *imageURL, NSError *error) {
        if (error) {
            NSLog(@"Error during upload: %@", error);
            [self updateUIForUploadFailureWithError:error];
        } else {
            [self updateUIForUploadSuccess:[imageURL absoluteString]];
            [[NSWorkspace sharedWorkspace] performSelector:@selector(openURL:) withObject:imageURL afterDelay:2.0];
        }
    }];
}

- (void)updateUIForUploadStart
{
    [self.uploadButton setEnabled:NO];
    [self.uploadProgressTextField setStringValue:@"Uploading..."];
    [self.uploadProgressIndicator startAnimation:nil];
}

- (void)updateUIForUploadFailureWithError:(NSError *)error
{
    [self.uploadButton setEnabled:YES];
    [self.uploadButton setTitle:@"Upload"];
    [self.uploadProgressTextField setStringValue:@"Upload failed"];
    [self.uploadProgressIndicator stopAnimation:nil];
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

- (void)updateUIForUploadSuccess:(NSString *)url
{
    [self.uploadProgressTextField setStringValue:@"Upload successful!"];
    [self.urlTextField setHidden:NO];
    [self.urlTextField setStringValue:url];
    [self.uploadProgressIndicator stopAnimation:nil];
}

#pragma mark - Protocol conformance
#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [self.delegate imageUploadControllerWillClose:self];
    [NSEvent removeMonitor:self.eventMonitor];
}

@end
