//
//  ABAirbugCommunicator.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugCommunicator.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "AFNetworking.h"

@interface ABAirbugCommunicator ()
@property (strong, nonatomic) WebView *webView;
@property (strong, nonatomic) NSHTTPCookie *authCookie;
@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) JSValue *bridge;
@property (strong, nonatomic) JSValue *sendMessageFunc;
@end

@implementation ABAirbugCommunicator

NSString * const ABAirbugCommunicatorError = @"ABAirbugCommunicatorError";
NSString * const AirbugImageUploadURL = @"http://localhost:3000/imageupload";
NSString * const AirbugVideoUploadURL = @"http://localhost:3000/videoupload";
NSString * const AirbugAPIBridgeURL = @"http://localhost:8000/client_api";
NSString * const AirbugCookieAPITokenKey = @"'airbug.sid'";


#pragma mark - Lifecycle

- (id)init
{
    if (self = [super init]) {
        _webView = [[WebView alloc] init];
        [_webView setResourceLoadDelegate:self];
        [_webView setFrameLoadDelegate:self];
        [self loadWebView];
        
        _authCookie = [self savedCookie];
    }
    return self;
}

#pragma mark - Custom accessors

- (BOOL)isLoggedIn
{
    return self.authCookie != nil;
}

#pragma mark - Public

- (void)sendPNGImageData:(NSData *)imageData withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self sendFileData:imageData mimeType:@"image/png" toURL:AirbugImageUploadURL withParameters:parameters onCompletion:^(NSDictionary *jsonDictionary, NSError *error) {
        completionHandler(jsonDictionary, error);
    }];
}

- (void)sendQuickTimeVideoFile:(NSURL *)fileURL withParameters:(NSDictionary *)parameters progress:(NSProgress **)progress onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self sendFile:fileURL mimeType:@"video/quicktime" toURL:AirbugVideoUploadURL withParameters:parameters progress:progress onCompletion:^(NSDictionary *jsonDictionary, NSError *error) {
        completionHandler(jsonDictionary, error);
    }];
}

- (void)logInWithUsername:(NSString *)username password:(NSString *)password onCompletion:(void (^)(NSError *))completionHandler
{
    if ([self isLoggedIn]) {
        if (completionHandler) completionHandler(nil);
        return;
    }
    
    // The irony of having the bridge message's function be named receiveMessage and assigning it to a variable called sendMessageFunc...
    void(^loginCallback)(id, id) = ^(NSString *message, NSString *JSONObject) {
        if (message && ![message isEqualToString:@"undefined"]) {
            NSLog(@"Message from callback: %@", message);

            NSError *error = [NSError errorWithDomain:ABAirbugCommunicatorError code:0 userInfo:@{NSLocalizedDescriptionKey : message}];
            if (completionHandler) completionHandler(error);
            return;
        }
        
        if (JSONObject && ![JSONObject isEqualToString:@"undefined"] && ![JSONObject isEqualToString:@"null"]) {
            NSData *JSONData = [JSONObject dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *currentUserMeldDocument = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
            NSLog(@"currentUserMeldDocument: %@", currentUserMeldDocument);
            NSLog(@"Your user ID is %@", [currentUserMeldDocument valueForKeyPath:@"value.data.id"]);
            
            if ([self saveLoginCookie]) {
                if (completionHandler) completionHandler(nil);
            } else {
                // TODO: call completion handler with error that cookie wasn't found?
            }
        }
    };

    NSString *loginJSONRequest = [self createLoginJSONStringForUsername:username password:password];
    [self sendJSONString:loginJSONRequest withCallback:loginCallback];
}

- (void)logOut
{
    if (self.authCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.authCookie];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authCookie"];
        
        self.authCookie = nil;
    }
}

#pragma mark - Private

- (void)loadWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:AirbugAPIBridgeURL]];
    [self.webView.mainFrame loadRequest:request];
}

// Callback params: first is throwable, second is a JSON object
- (void)sendJSONString:(NSString *)JSONString withCallback:(void(^)(id, id))callback
{
    if (!self.sendMessageFunc) {
        [self loadWebView];
        if (callback) callback(@"Network connection unavailable, please try again", nil);
    } else {
        [self.sendMessageFunc callWithArguments:@[JSONString, callback]];
    }
}

- (void)receivedJSONString:(NSString *)JSONString
{
    NSLog(@"Received JSON string: %@", JSONString);

    // TODO: NSNotification broadcast?
}

- (void)sendFileData:(NSData *)fileData mimeType:(NSString *)mimeType toURL:(NSString *)urlString withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *jsonDictionary, NSError *error))completionHandler
{
    NSParameterAssert(fileData);
    
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } error:nil];
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[self.authCookie]];
    [request setAllHTTPHeaderFields:headers];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            if (error) {
                completionHandler(nil, error);
            } else {
                completionHandler(responseObject, nil);
            }
        }
    }];
    
    [dataTask resume];
}

- (void)sendFile:(NSURL *)fileURL mimeType:(NSString *)mimeType toURL:(NSString *)urlString withParameters:(NSDictionary *)parameters progress:(NSProgress **)progress onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:[fileURL path]] name:@"file" fileName:fileName mimeType:mimeType error:nil];
    } error:nil];
    
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:@[self.authCookie]];
    [request setAllHTTPHeaderFields:headers];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            completionHandler(responseObject, nil);
        }
    }];
    
    [uploadTask resume];
}

// TODO: figure out where the JSON format for a login message should be encapsulated.
// Should there be one class that's responsible for all JSON parsing?
- (NSString *)createLoginJSONStringForUsername:(NSString *)username password:(NSString *)password
{
    NSDictionary *jsonDictionary =
    @{
      @"class" : @"currentUserManager",
      @"action" : @"login",
      @"username" : username,
      @"password" : password
      };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSHTTPCookie *)savedCookie
{
    NSHTTPCookie *savedCookie;
    
    // Note: Saving and retrieving the cookie in user defaults may not be necessary if the expiresDate doesn't matter and sessionOnly remains false.
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"authCookie"];
    if (cookieProperties) {
        savedCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSLog(@"Found cookie in user defaults: %@", savedCookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:savedCookie];
    } else {
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if ([[cookie name] isEqualToString:AirbugCookieAPITokenKey]) {
                NSLog(@"%@", cookie);
                savedCookie = cookie;
                break;
            }
        }
    }
    return savedCookie;
}

// Returns YES if successful
- (BOOL)saveLoginCookie
{
    NSURL *url = [NSURL URLWithString:AirbugAPIBridgeURL];
    NSString *domain = [url host];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie domain] isEqualToString:domain] &&
            [[cookie name] isEqualToString:AirbugCookieAPITokenKey])
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
            
            return YES;
        }
    }
    return NO;
}

#pragma mark - Protocol conformance

#pragma mark WebResourceLoadDelegate

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    self.jsContext = context;
}

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
        self.sendMessageFunc = self.bridge[@"receiveMessage"];

        __weak ABAirbugCommunicator *weakSelf = self;
        self.bridge[@"receiverCallback"] = ^(NSString *JSONString) {
            [weakSelf receivedJSONString:JSONString];
        };
    }
}

@end
