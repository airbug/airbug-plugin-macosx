//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABAirbugManager.h"
#import "ABImageUploadWindowController.h"
#import "ABVideoUploadWindowController.h"
#import "ABLoginWindowController.h"
#import "ABWebViewWindowController.h"
#import "ABWebViewWindow.h"

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *mainStatusItem;
@property (strong, nonatomic) NSStatusItem *stopRecordingStatusItem;
@property (strong, nonatomic) ABCaptureManager *captureController;
@property (strong, nonatomic) NSMutableArray *uploadControllers;
@property (strong, nonatomic) ABAirbugManager *manager;
@property (strong, nonatomic) ABNetworkCommunicator *communicator;
@property (strong, nonatomic) ABLoginWindowController *loginWindowController;

// Experimental
@property (strong, nonatomic) ABWebViewWindowController *webViewWindowController;

@end

@implementation ABAppDelegate

#pragma mark - Lifecycle

//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//}

- (void)awakeFromNib
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.mainStatusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    self.mainStatusItem.image = [NSImage imageNamed:@"StatusMenuIcon"];
    self.mainStatusItem.title = @"";
    self.mainStatusItem.highlightMode = YES;
    self.mainStatusItem.menu = self.statusMenu;
    
    self.captureController = [[ABCaptureManager alloc] init];
    self.captureController.delegate = self;
    
    self.uploadControllers = [NSMutableArray array];
    
    // Create the main WebView. It will be displayed in a window, but it's also used by the ABNetworkCommunicator
    // to perform all communication with the server
    self.webViewWindowController = [[ABWebViewWindowController alloc] init];
    ABWebViewWindow *webViewWindow = (ABWebViewWindow *)self.webViewWindowController.window;
    WebView *webView = webViewWindow.webView;
    [webViewWindow orderOut:self];
    
    self.communicator = [[ABNetworkCommunicator alloc] initWithWebView:webView];
    self.manager = [[ABAirbugManager alloc] initWithCommunicator:self.communicator
                                             incomingDataBuilder:[[ABIncomingDataBuilder alloc] init]
                                             outgoingDataBuilder:[[ABOutgoingDataBuilder alloc] init]];
    
    // Hook up our response to various messages from the airbug server
    __weak ABAppDelegate *weakSelf = self;
    self.manager.notificationHandler = ^(NSUserNotification *notification) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    };
    self.manager.windowVisibilityRequestHandler = ^(BOOL showWindow) {
        if (showWindow) {
            [weakSelf.webViewWindowController showWindow:nil];
        } else {
            [weakSelf.webViewWindowController.window orderOut:nil];
        }
    };
    self.manager.windowResizeRequestHandler = ^(NSSize windowSize) {
        // Resize the WebView window
        [weakSelf.webViewWindowController.window setContentSize:windowSize];
    };
    
    if (self.manager.isLoggedIn) {
        [self setUpLoggedInUI];
    } else {
        [self setUpLoggedOutUI];
    }

#ifdef DEBUG
    // Set up debug menu options to send preprogrammed notifications
    NSMenuItem *debugMenuItem = [[NSMenuItem alloc] init];
    debugMenuItem.title = @"Debug Messages";
    NSMenu *debugSubmenu = [[NSMenu alloc] initWithTitle:@"Debug"];
    [debugSubmenu addItemWithTitle:@"Notification" action:@selector(sendNotification:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Show Window" action:@selector(showWindow:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Hide Window" action:@selector(hideWindow:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Resize Window" action:@selector(resizeWindow:) keyEquivalent:@""];
    debugMenuItem.submenu = debugSubmenu;
    [self.mainStatusItem.menu addItem:debugMenuItem];
#endif
}

#pragma mark - IBAction

- (IBAction)logIn:(id)sender
{
    self.loginWindowController = [[ABLoginWindowController alloc] initWithManager:self.manager];
    
    __weak ABAppDelegate *weakSelf = self;
    self.loginWindowController.onSuccessfulLogin = ^{
        [weakSelf setUpLoggedInUI];
    };
    [self.loginWindowController showWindow:nil];
}

- (IBAction)takeScreenshot:(id)sender {
    [self.captureController captureScreenshot];
}

- (IBAction)captureArea:(id)sender {
    [self.captureController captureTargetedScreenshot];
}

- (IBAction)quit:(id)sender {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.mainStatusItem];
    [[NSApplication sharedApplication] stop:nil];
}

- (IBAction)captureScreenRecording:(id)sender {
    [self.captureController startVideoScreenCapture];

    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.stopRecordingStatusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    self.stopRecordingStatusItem.image = [NSImage imageNamed:@"StopCaptureIcon"];
    self.stopRecordingStatusItem.title = @"Click to stop recording";
    self.stopRecordingStatusItem.target = self;
    self.stopRecordingStatusItem.action = @selector(stopRecording:);
}

- (void)stopRecording:(id)sender {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.stopRecordingStatusItem];
    self.stopRecordingStatusItem = nil;
    [self.captureController stopVideoScreenCapture];
}

- (IBAction)logOut:(id)sender
{
    [self.manager logOut];
    [self setUpLoggedOutUI];
}

#pragma mark - Stub debugging methods

- (IBAction)sendNotification:(id)sender
{
    NSDictionary *notification = @{
                           @"type" : @"UserNotification",
                           @"data" : @{
                                       @"title": @"Test Title",
                                       @"subtitle" : @"Test subtitle",
                                       @"informativeText" : @"This is a test message"
                                   }
                           };
    [self sendJSONDictionaryToCommunicator:notification];
}

- (IBAction)showWindow:(id)sender
{
    NSDictionary *notification = @{
                                   @"type" : @"ShowWindow"
                                   };
    [self sendJSONDictionaryToCommunicator:notification];
}

- (IBAction)hideWindow:(id)sender
{
    NSDictionary *notification = @{
                                   @"type" : @"HideWindow"
                                   };
    [self sendJSONDictionaryToCommunicator:notification];
}

- (IBAction)resizeWindow:(id)sender
{
    NSDictionary *notification = @{
                                   @"type" : @"ResizeWindow",
                                   @"data" : @{
                                           @"width": @(400),
                                           @"height" : @(400)
                                           }
                                   };
    [self sendJSONDictionaryToCommunicator:notification];
}

- (void)sendJSONDictionaryToCommunicator:(NSDictionary *)dictionary
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    [self.communicator receivedJSONString:JSONString];
}

#pragma mark - Private

- (void)displayImageInPreviewWindow:(NSImage *)image
{
//    ABImageUploadWindowController *controller = [[ABImageUploadWindowController alloc] initWithManager:self.manager];
//    controller.delegate = self;
//    controller.image = image;
//    [controller showWindow:nil];
//    [self.uploadControllers addObject:controller];
}

- (void)displayVideoInPreviewWindow:(NSURL *)file
{
//    ABVideoUploadWindowController *controller = [[ABVideoUploadWindowController alloc] initWithManager:self.manager];
//    controller.fileURL = file;
//    controller.delegate = self;
//    [controller showWindow:nil];
//    [self.uploadControllers addObject:controller];
}

- (void)setUpLoggedOutUI
{
    [self setUpUI:NO];
}

- (void)setUpLoggedInUI
{
    [self setUpUI:YES];
}

- (void)setUpUI:(BOOL)isLoggedIn
{
    [[self.statusMenu itemAtIndex:0] setHidden:isLoggedIn];
    [[self.statusMenu itemAtIndex:1] setHidden:!isLoggedIn];
    [[self.statusMenu itemAtIndex:2] setHidden:!isLoggedIn];
    [[self.statusMenu itemAtIndex:4] setHidden:!isLoggedIn];
}

#pragma mark - Protocol conformance
#pragma mark ABScreenCaptureControllerDelegate

- (void)didCaptureImage:(NSImage *)image
{
//    [self displayImageInPreviewWindow:image];
}

- (void)didCaptureFile:(NSURL *)file
{
//    [self displayVideoInPreviewWindow:file];
//    NSLog(@"Captured file: %@", file);
}

#pragma mark ABUploadWindowControllerDelegate

- (void)uploadWindowControllerWillClose:(ABUploadWindowController *)controller
{
    [self.uploadControllers removeObject:controller];
}

@end
