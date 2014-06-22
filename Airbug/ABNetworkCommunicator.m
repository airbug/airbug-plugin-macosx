//
//  ABNetworkCommunicator.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABNetworkCommunicator.h"
#import <JavaScriptCore/JavaScriptCore.h>
//#import "AFNetworking.h"

@interface ABNetworkCommunicator ()

@property (strong, nonatomic) JSContext *jsContext;
@property (strong, nonatomic) JSValue *jsWindow;
@property (strong, nonatomic) WebScriptObject *scriptObject;

@end

@implementation ABNetworkCommunicator

NSString * const ABNetworkCommunicatorError = @"ABNetworkCommunicatorError";
NSString * const AirbugImageUploadURL = @"http://localhost:3000/imageupload";
NSString * const AirbugVideoUploadURL = @"http://localhost:3000/videoupload";
NSString * const AirbugAPIBridgeURL = @"http://localhost:8000/client_api";

#pragma mark - Lifecycle

// TODO: Do we need to pass the auth cookie as well?
- (id)initWithWebView:(WebView *)webView
{
    if (self = [super init]) {
        _webView = webView;
        [_webView setResourceLoadDelegate:self];
        [_webView setFrameLoadDelegate:self];
        [self loadWebView];
    }
    return self;
}

#pragma mark - Public

- (BOOL)sendJSONObject:(id)JSONObject error:(NSError *__autoreleasing *)error
{
    if (!self.jsWindow) {
        [self loadWebView];
        *error = [NSError errorWithDomain:ABNetworkCommunicatorError code:0 userInfo:@{ NSLocalizedDescriptionKey : @"Network connection unavailable" }];
        return NO;
    }
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:NULL];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    
    NSString *type = JSONObject[@"type"];
    if (type) {
        NSLog(@"Sending JSON string of type %@", JSONObject[@"type"]);
    } else {
        NSLog(@"Sending JSON string: %@", JSONString);
    }
    NSData * data = [NSPropertyListSerialization dataFromPropertyList:JSONObject format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    if (data.length < 4096) {
        NSLog(@"JSON string: %@", JSONObject);
    } else {
        NSLog(@"Omitting console dump of JSON string - string length (%lu)", (unsigned long)data.length);
    }
    
    JSValue *sendFunc = self.jsWindow[@"receiveMessage"];
    [sendFunc callWithArguments:@[JSONString]];
    
    return YES;
}

- (void)receivedJSONString:(NSString *)JSONString
{
    NSLog(@"Received JSON string: %@", JSONString);
    
    NSError *error;
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    
    if (!JSONDictionary) {
        NSLog(@"JSON parsing error in receivedJSONString: %@", error);
        return;
    }
    
    if (self.receivedJSONObjectHandler) {
        self.receivedJSONObjectHandler(JSONDictionary);
    }
}

#pragma mark - Private

- (void)loadWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:AirbugAPIBridgeURL]];
    [self.webView.mainFrame loadRequest:request];
}

#pragma mark - Protocol conformance

#pragma mark WebResourceLoadDelegate

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    self.jsContext = context;
    
    // Allows the communicator to be accessible inside the bridge via "native" and to have
    // console.log() actually pipe to us. Amazing.
    self.jsContext[@"console"][@"log"] = ^(NSString *message) {
        NSLog(@"JSLog: %@", message);
    };
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
        self.jsWindow = self.jsContext[@"window"];

        __weak ABNetworkCommunicator *weakSelf = self;
        self.jsWindow[@"bridge"][@"receiverCallback"] = ^(NSString *JSONString) {
            [weakSelf receivedJSONString:JSONString];
        };
    }
}

@end
