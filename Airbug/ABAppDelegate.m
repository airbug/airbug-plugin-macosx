//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABScreenCapturer.h"

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) ABScreenCapturer *capturer;
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
    
    self.capturer = [[ABScreenCapturer alloc] init];
}

#pragma mark - IBAction

- (IBAction)takeScreenshot:(id)sender {
    NSImage *screenshot = [self.capturer captureMainDisplay];
    NSLog(@"screenshot: %@", screenshot);
}

- (IBAction)captureArea:(id)sender {
    [self.capturer displayOverlayOnMainDisplay];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] stop:nil];
}

@end
