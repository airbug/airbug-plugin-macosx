//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) ABScreenCaptureController *captureController;
@property (strong, nonatomic) NSWindow *imagePreviewWindow;
@end

@implementation ABAppDelegate

#pragma mark - Lifecycle

//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//}

- (void)awakeFromNib
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"StatusMenuIcon"];
    self.statusItem.title = @"";
    self.statusItem.highlightMode = YES;
    self.statusItem.menu = self.statusMenu;
    
    self.captureController = [[ABScreenCaptureController alloc] init];
    self.captureController.delegate = self;
}

#pragma mark - IBAction

- (IBAction)takeScreenshot:(id)sender {
    [self.captureController takeScreenshot];
}

- (IBAction)captureArea:(id)sender {
    [self.captureController captureArea];
}

- (IBAction)quit:(id)sender {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    [[NSApplication sharedApplication] stop:nil];
}

#pragma mark - Private

- (void)displayImageInPreviewWindow:(NSImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSScreen *mainScreen = [NSScreen mainScreen];
    NSRect centeredRect = NSMakeRect((mainScreen.frame.size.width / 2.0) - 200,
                                     (mainScreen.frame.size.height / 2.0) - 200, 400.0, 400.0);
    self.imagePreviewWindow = [[NSWindow alloc] initWithContentRect:centeredRect
                                                          styleMask:NSClosableWindowMask|NSTitledWindowMask
                                                            backing:NSBackingStoreBuffered
                                                              defer:NO
                                                             screen:mainScreen];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 400.0, 400.0)];
    imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
    imageView.image = image;
    self.imagePreviewWindow.contentView = imageView;
    [self.imagePreviewWindow orderFront:nil];
    });
}

#pragma mark - Protocol conformance
#pragma mark ABScreenCaptureControllerDelegate

- (void)didTakeScreenshot:(NSImage *)image
{
    NSLog(@"Took screenshot: %@", image);
    [self displayImageInPreviewWindow:image];
}

- (void)didCaptureArea:(NSImage *)image
{
    NSLog(@"Captured area: %@", image);
    [self displayImageInPreviewWindow:image];
}

@end
