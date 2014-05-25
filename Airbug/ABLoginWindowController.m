//
//  ABLoginWindowController.m
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABLoginWindowController.h"

@interface ABLoginWindowController ()
@property (weak) IBOutlet NSTextField *emailTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton *signInButton;
@property (weak) IBOutlet NSTextField *messageTextField;
@property (nonatomic) id eventMonitor;
@end

@implementation ABLoginWindowController

- (id)initWithManager:(ABAirbugManager *)manager
{
    if (self = [super initWithWindowNibName:[self windowNibName] owner:self]) {
        _manager = manager;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:self];
    
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

#pragma mark - IBActions

- (IBAction)signIn:(id)sender
{
    NSString *username = [self.emailTextField stringValue];
    NSString *password = [self.passwordTextField stringValue];
    [self.messageTextField setStringValue:@""];
    
    NSLog(@"*** Signing in ***");
    NSLog(@"Username: %@", username);
    NSLog(@"Password: %@", password);
    
    CGFloat dimensionSize = CGRectGetHeight(self.signInButton.bounds) - 10;
    NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:(NSRect){CGRectGetMidX(self.signInButton.bounds)-(dimensionSize/2), (CGRectGetHeight(self.signInButton.bounds)-dimensionSize)/2, dimensionSize, dimensionSize}];
    [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
    [progressIndicator setDisplayedWhenStopped:YES];
    [self.signInButton addSubview:progressIndicator];
    [progressIndicator startAnimation:self];
    [self.signInButton setEnabled:NO];
    
    [self.manager logInWithUsername:username password:password onCompletion:^(BOOL success, NSError *error) {
        [progressIndicator stopAnimation:self];
        [progressIndicator removeFromSuperview];
        [self.signInButton setEnabled:YES];
        
        if (!success) {
            NSLog(@"Error logging in: %@", [error localizedDescription]);
            [self.messageTextField setStringValue:[error localizedDescription]];
            return;
        }
        if (self.onSuccessfulLogin) self.onSuccessfulLogin();
    }];
}

#pragma mark - Public methods

- (NSString *)windowNibName {
    return @"ABAirbugLoginWindow";
}

#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [NSEvent removeMonitor:self.eventMonitor];
}

@end
