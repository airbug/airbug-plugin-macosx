//
//  ABAppDelegate.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAppDelegate.h"
#import "ABAirbugManager.h"
#import "ABAirbugLoginManager.h"
#import "ABImageUploadWindowController.h"
#import "ABVideoUploadWindowController.h"
#import "ABAirbugLoginWindowController.h"

@interface ABAppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *mainStatusItem;
@property (strong, nonatomic) NSStatusItem *stopRecordingStatusItem;
@property (strong, nonatomic) ABCaptureManager *captureController;
@property (strong, nonatomic) NSMutableArray *uploadControllers;
@property (strong, nonatomic) ABAirbugManager *manager;
@property (strong, nonatomic) ABAirbugCommunicator *communicator;
@property (strong, nonatomic) ABAirbugLoginWindowController *loginController;
@property (strong, nonatomic) ABAirbugLoginManager *loginManager;
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
    
    self.communicator = [[ABAirbugCommunicator alloc] init];
    self.manager = [[ABAirbugManager alloc] initWithCommunicator:self.communicator
                                             incomingDataBuilder:[[ABIncomingDataBuilder alloc] init]
                                             outgoingDataBuilder:[[ABOutgoingDataBuilder alloc] init]];
    self.loginManager = [[ABAirbugLoginManager alloc] initWithCommunicator:self.communicator];

    NSHTTPCookie *authCookie = [self authCookie];
    if (authCookie) {
        self.communicator.authCookie = authCookie;
        [self setUpLoggedInUI];
    } else {
        [self setUpLoggedOutUI];
    }
}

#pragma mark - IBAction

- (IBAction)logIn:(id)sender
{
    self.loginController = [[ABAirbugLoginWindowController alloc] initWithManager:self.loginManager];
    
    __weak ABAppDelegate *weakSelf = self;
    self.loginController.onSuccessfulLogin = ^{
        [weakSelf setUpLoggedInUI];
        // TODO: figure out if HTTP requests automatically contain cookies
        weakSelf.communicator.authCookie = [weakSelf authCookie];
    };
    
    [self.loginController showWindow:nil];
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
    NSHTTPCookie *authCookie;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie name] isEqualToString:@"'airbug.sid'"]) {
            authCookie = cookie;
            break;
        }
    }

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:authCookie];
    self.communicator.authCookie = nil;
    
    [self setUpLoggedOutUI];
}

#pragma mark - Private

- (void)displayImageInPreviewWindow:(NSImage *)image
{
    ABImageUploadWindowController *controller = [[ABImageUploadWindowController alloc] initWithManager:self.manager];
    controller.delegate = self;
    controller.image = image;
    [controller showWindow:nil];
    [self.uploadControllers addObject:controller];
}

- (void)displayVideoInPreviewWindow:(NSURL *)file
{    
    ABVideoUploadWindowController *controller = [[ABVideoUploadWindowController alloc] initWithManager:self.manager];
    controller.fileURL = file;
    controller.delegate = self;
    [controller showWindow:nil];
    [self.uploadControllers addObject:controller];
}

- (NSHTTPCookie *)authCookie
{
    NSHTTPCookie *authCookie;

    // Note: Saving and retrieving the cookie in user defaults may not be necessary if the expiresDate doesn't mater and sessionOnly remains false.
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"authCookie"];
    if (cookieProperties) {
        authCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSLog(@"Found cookie in user defaults: %@", authCookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:authCookie];
    } else {
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if ([[cookie name] isEqualToString:@"'airbug.sid'"]) {
                NSLog(@"%@", cookie);
                authCookie = cookie;
                break;
            }
        }
    }
    return authCookie;
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
    [self displayImageInPreviewWindow:image];
}

- (void)didCaptureFile:(NSURL *)file
{
    [self displayVideoInPreviewWindow:file];
    NSLog(@"Captured file: %@", file);
}

#pragma mark ABUploadWindowControllerDelegate

- (void)uploadWindowControllerWillClose:(ABUploadWindowController *)controller
{
    [self.uploadControllers removeObject:controller];
}

@end
