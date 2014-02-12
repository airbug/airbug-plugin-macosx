//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABAirbugManager.h"

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) ABScreenCaptureController *captureController;
@property (strong, nonatomic) NSMutableArray *imageUploadControllers;
@property (strong, nonatomic) ABAirbugManager *manager;
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
    
    self.imageUploadControllers = [NSMutableArray array];
    
    self.manager = [[ABAirbugManager alloc] initWithCommunicator:[[ABAirbugCommunicator alloc] init]
                                             incomingDataBuilder:[[ABIncomingDataBuilder alloc] init]
                                             outgoingDataBuilder:[[ABOutgoingDataBuilder alloc] init]];
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
    ABImageUploadWindowController *controller = [[ABImageUploadWindowController alloc] initWithManager:self.manager];
    controller.delegate = self;
    controller.image = image;
    [controller showWindow:nil];
    [self.imageUploadControllers addObject:controller];
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

#pragma mark ABImageUploadWindowControllerDelegate

- (void)imageUploadControllerWillClose:(ABImageUploadWindowController *)controller
{
    [self.imageUploadControllers removeObject:controller];
}

@end
