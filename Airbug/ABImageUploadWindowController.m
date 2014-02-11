//
//  ABImageUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABImageUploadWindowController.h"

@interface ABImageUploadWindowController ()
@property (weak) IBOutlet NSImageView *imageView;
@property (nonatomic) id eventMonitor;
@end

@implementation ABImageUploadWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"ABImageUploadWindow" owner:self];
    if (self) {
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
    [sender setEnabled:NO];
    [sender setTitle:@"Uploading..."];
    // TODO: Start upload
}

#pragma mark - Protocol conformance
#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [self.delegate imageUploadControllerWillClose:self];
    [NSEvent removeMonitor:self.eventMonitor];
}

@end
