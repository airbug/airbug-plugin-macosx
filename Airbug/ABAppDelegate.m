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
}

#pragma mark - IBAction

- (IBAction)takeScreenshot:(id)sender {
    CGImageRef image = CGDisplayCreateImage(kCGDirectMainDisplay);
    NSImage *screenshot = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
    CGImageRelease(image);
    
    NSLog(@"screenshot: %@", screenshot);
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] stop:nil];
}

@end
