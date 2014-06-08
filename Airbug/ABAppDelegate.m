//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABImageUploadWindowController.h"
#import "ABVideoUploadWindowController.h"
#import "ABLoginWindowController.h"
#import "ABWebViewWindowController.h"
#import "ABWebViewWindow.h"
#import "ABScreenshotRequest.h" // TODO: move ABScreenshotType out of this class...

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *mainStatusItem;
@property (strong, nonatomic) NSStatusItem *stopRecordingStatusItem;
@property (strong, nonatomic) ABCaptureManager *captureController;
@property (strong, nonatomic) NSMutableArray *uploadControllers;
@property (strong, nonatomic) ABAirbugManager *manager;
@property (strong, nonatomic) ABNetworkCommunicator *communicator;
@property (strong, nonatomic) ABLoginWindowController *loginWindowController;
@property (strong, nonatomic) ABWebViewWindowController *webViewWindowController;

// TODO: Move all window management logic to a new class - ABWindowManager
// The app delegate is getting to be too heavyweight. It will be better to encapsulate more
// of this window management logic to a new class

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
    
    // RSS: We keep a reference to the communicator *only* for the purposes of debugging and
    // sending stub messages to the communicator. All interaction with the network layer is done
    // through the ABAirbugManager class
    self.communicator = [[ABNetworkCommunicator alloc] initWithWebView:webView];
    self.manager = [[ABAirbugManager alloc] initWithCommunicator:self.communicator
                                             incomingDataBuilder:[[ABIncomingDataBuilder alloc] init]
                                             outgoingDataBuilder:[[ABOutgoingDataBuilder alloc] init]];
    self.manager.delegate = self;
    
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
    [debugSubmenu addItemWithTitle:@"Notification" action:@selector(receiveStubNotificationMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"ShowWindow" action:@selector(receiveStubMessageTypeWithMenuItemTitle:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"HideWindow" action:@selector(receiveStubMessageTypeWithMenuItemTitle:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Resize Window" action:@selector(receiveStubResizeWindowMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"ShowLoginPage" action:@selector(sendStubMessageTypeWithMenuItemTitle:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Logout" action:@selector(sendStubMessageTypeWithMenuItemTitle:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Open Browser" action:@selector(receiveStubOpenBrowserMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Save cookie" action:@selector(receiveStubSaveCookieMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Restore cookie" action:@selector(receiveStubRestoreCookieMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Restore cookie ack" action:@selector(sendStubAckMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"FullScreen Screenshot" action:@selector(receiveStubScreenshotMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Crosshair Screenshot" action:@selector(receiveStubScreenshotMessage:) keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Timed Screenshot" action:@selector(receiveStubScreenshotMessage:) keyEquivalent:@""];
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

- (IBAction)takeFullScreenScreenshot:(id)sender {
    [self.captureController captureScreenshot];
}

- (IBAction)takeCrosshairScreenshot:(id)sender {
    [self.captureController captureTargetedScreenshot];
}

- (IBAction)takeTimedScreenshot:(id)sender {
    [self.captureController captureTimedScreenshot];
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

- (IBAction)receiveStubMessageTypeWithMenuItemTitle:(NSMenuItem *)menuItem {
    [self haveCommunicatorReceiveJSONDictionary:@{ @"type" : menuItem.title }];
}

- (IBAction)sendStubMessageTypeWithMenuItemTitle:(NSMenuItem *)menuItem {
    [self haveCommunicatorSendJSONDictionary:@{ @"type" : menuItem.title }];
}

- (IBAction)receiveStubNotificationMessage:(id)sender
{
    NSDictionary *notification = @{
                           @"type" : @"UserNotification",
                           @"data" : @{
                                       @"title": @"Test Title",
                                       @"subtitle" : @"Test subtitle",
                                       @"informativeText" : @"This is a test message"
                                   }
                           };
    [self haveCommunicatorReceiveJSONDictionary:notification];
}

- (IBAction)receiveStubResizeWindowMessage:(id)sender
{
    NSDictionary *message = @{
                              @"type" : @"ResizeWindow",
                              @"data" : @{
                                          @"width": @(400),
                                          @"height" : @(400)
                                        }
                              };
    [self haveCommunicatorReceiveJSONDictionary:message];
}

- (IBAction)receiveStubOpenBrowserMessage:(id)sender
{
    NSDictionary *message = @{
                              @"type" : @"OpenBrowser",
                              @"data" : @{
                                      @"url": @"http://www.google.com"
                                      }
                              };
    [self haveCommunicatorReceiveJSONDictionary:message];
}

- (IBAction)receiveStubSaveCookieMessage:(id)sender {
    NSDictionary *message = @{
                              @"type" : @"SaveCookie",
                              @"data" : @{
                                      @"cookieName": @"airbug.sid"
                                      }
                              };
    [self haveCommunicatorReceiveJSONDictionary:message];
}

- (IBAction)receiveStubRestoreCookieMessage:(id)sender {
    NSDictionary *message = @{
                              @"type" : @"RestoreCookie",
                              @"data" : @{
                                      @"cookieName": @"airbug.sid"
                                      },
                              @"messageId" : @"abcdefghijklmnop"
                              };
    [self haveCommunicatorReceiveJSONDictionary:message];
}

- (IBAction)sendStubAckMessage:(id)sender {
    NSDictionary *message = @{
                              @"ackId" : @"abcdefghijklmnop"
                              };
    [self haveCommunicatorSendJSONDictionary:message];
}

- (IBAction)receiveStubScreenshotMessage:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *screenshotType = [[item.title componentsSeparatedByString:@" "] firstObject];
    NSDictionary *message = @{
                              @"type" : @"TakeScreenshot",
                              @"data" : @{
                                      @"type" : screenshotType
                                      }
                              };
    [self haveCommunicatorReceiveJSONDictionary:message];
}

- (void)haveCommunicatorReceiveJSONDictionary:(NSDictionary *)dictionary
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    [self.communicator receivedJSONString:JSONString];
}

- (void)haveCommunicatorSendJSONDictionary:(NSDictionary *)dictionary
{
    [self.communicator sendJSONObject:dictionary error:NULL];
}

#pragma mark - Private

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

- (void)didCaptureScreenshot:(NSImage *)image {
    [self.manager sendPreviewScreenshotRequestForImage:image ofType:ABScreenshotTypeFullScreen];
}

- (void)didCaptureTargetedScreenshot:(NSImage *)image {
    [self.manager sendPreviewScreenshotRequestForImage:image ofType:ABScreenshotTypeCrosshair];
}

- (void)didCaptureTimedScreenshot:(NSImage *)image {
    [self.manager sendPreviewScreenshotRequestForImage:image ofType:ABScreenshotTypeTimed];
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

#pragma mark ABAirbugManagerDelegate

- (void)failedToSendJSONObject:(id)JSONObject error:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert runModal];
}

- (void)didLogInSuccessfully {
    // TODO: ???
}

- (void)loginFailedWithError:(NSError *)error {
    // TODO: ???
}

- (void)didReceiveNotification:(NSUserNotification *)notification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)didReceiveWindowVisibilityRequest:(BOOL)showWindow {
    if (showWindow) {
        [self.webViewWindowController showWindow:nil];
        [self.webViewWindowController.window makeKeyWindow];
        // This forces the window to the front, even when the app isn't active. makeKeyAndOrderFront
        // doesn't do this reliably enough.
        [self.webViewWindowController.window orderFrontRegardless];
    } else {
        [self.webViewWindowController.window orderOut:nil];
    }
}

- (void)didReceiveWindowResizeRequest:(NSSize)size {
    [self.webViewWindowController.window setContentSize:size];
}

- (void)didReceiveScreenshotRequest:(ABScreenshotType)screenshotType
{
    if (screenshotType == ABScreenshotTypeFullScreen) {
        [self takeFullScreenScreenshot:nil];
    } else if (screenshotType == ABScreenshotTypeCrosshair) {
        [self takeCrosshairScreenshot:nil];
    } else if (screenshotType == ABScreenshotTypeTimed) {
        [self takeTimedScreenshot:nil];
    }
}

- (void)didReceiveOpenBrowserRequest:(NSURL *)url {
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
