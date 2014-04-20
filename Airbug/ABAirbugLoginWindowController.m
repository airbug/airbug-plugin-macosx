//
//  ABAirbugLoginWindowController.m
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugLoginWindowController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ABAirbugLoginWindowController ()
@property (strong, nonatomic) WebView *webView;
@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) JSValue *bridge;
@property (weak) IBOutlet NSTextField *emailTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@end

@implementation ABAirbugLoginWindowController

NSString *const APIUrl = @"http://localhost:8000/client_api";
NSString *const CookieAPITokenKey = @"'airbug.sid'";

- (id)initWithManager:(ABAirbugLoginManager *)manager
{
    if (self = [super initWithWindowNibName:[self windowNibName] owner:self]) {
        _manager = manager;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.webView = [[WebView alloc] init];
    [self.webView setResourceLoadDelegate:self];
    [self.webView setFrameLoadDelegate:self];
    
    NSURL *loginURL = [NSURL URLWithString:APIUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:loginURL];
    [self.webView.mainFrame loadRequest:request];
}

#pragma mark - IBActions

- (IBAction)signIn:(id)sender
{
    NSString *username = [self.emailTextField stringValue];
    NSString *password = [self.passwordTextField stringValue];
    
    NSLog(@"*** Signing in ***");
    NSLog(@"Username: %@", username);
    NSLog(@"Password: %@", password);
    
    // The irony of having the bridge message's function be named receiveMessage and assigning it to a variable called sendMessageFunc...
    void(^loginCallback)(id, id) = ^(NSString *message, NSString *JSONObject) {
        if (message && ![message isEqualToString:@"undefined"]) {
            NSLog(@"Message from callback: %@", message);
            // TODO: put up error message
        }
        
        if (JSONObject && ![JSONObject isEqualToString:@"undefined"] && ![JSONObject isEqualToString:@"null"]) {
            NSData *JSONData = [JSONObject dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *currentUserMeldDocument = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
            NSLog(@"currentUserMeldDocument: %@", currentUserMeldDocument);
            NSLog(@"Your user ID is %@", [currentUserMeldDocument valueForKeyPath:@"value.data.id"]);
            
            [self saveLoginCookie];
        }
    };
    
    JSValue *sendMessageFunc = self.bridge[@"receiveMessage"];
    [sendMessageFunc callWithArguments:@[[self createLoginJSONString], loginCallback]];
}



#pragma mark - Public methods

- (NSString *)windowNibName {
    return @"ABAirbugLoginWindow";
}

#pragma mark - Private methods

// TODO: figure out where the JSON format for a login message should be encapsulated.
// Should there be one class that's responsible for all JSON parsing?
- (NSString *)createLoginJSONString
{
    NSDictionary *jsonDictionary =
            @{
             @"class" : @"currentUserManager",
             @"action" : @"login",
             @"username" : [self.emailTextField stringValue],
             @"password" : [self.passwordTextField stringValue]
             };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)saveLoginCookie
{
    NSURL *url = [NSURL URLWithString:APIUrl];
    NSString *domain = [url host];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie domain] isEqualToString:domain] &&
            [[cookie name] isEqualToString:CookieAPITokenKey])
        {
            NSLog(@"Cookie: %@", [cookie value]);
            
            //    Get the cookie you want to modify from [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]
            //    Copy its properties to a new NSMutableDictionary , changing the "Expires" value to a date in the future.
            //    Create a new cookie from the new NSMutableDictionary using: [NSHTTPCookie.cookieWithProperties:]
            //    Save the newly created cookie using [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie newCookie]
            NSMutableDictionary *cookieDictionary = [NSMutableDictionary dictionaryWithDictionary:cookie.properties];
            cookieDictionary[@"Expires"] = [NSDate distantFuture];
            NSHTTPCookie *savedCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:savedCookie];
            
            [[NSUserDefaults standardUserDefaults] setObject:savedCookie.properties forKey:@"authCookie"];
            
            if (self.onSuccessfulLogin) {
                self.onSuccessfulLogin();
            }
            break;
        }
    }
}

#pragma mark - Protocol conformance

- (id)webView:(WebView *)webView identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
    NSString *url = [request.URL absoluteString];
    NSRange range = [url rangeOfString:@"airbug-api-bridge.js"];
    if (range.location != NSNotFound) {
        return @"identifier";
    }
    return nil;
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    if (identifier && [identifier isEqualToString:@"identifier"]) {
        self.bridge = self.jsContext[@"bridge"];
    }
}

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    self.jsContext = context;
}

@end
