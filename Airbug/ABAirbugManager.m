//
//  ABAirbugManager.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugManager.h"
#import "ABLoginResponse.h"
#import "ABWindowVisibilityRequest.h"
#import "ABWindowResizeRequest.h"
#import "ABBrowserRequest.h"

@interface ABAirbugManager ()

@property (strong, nonatomic) ABNetworkCommunicator *communicator;
@property (strong, nonatomic) ABIncomingDataBuilder *incomingBuilder;
@property (strong, nonatomic) ABOutgoingDataBuilder *outgoingBuilder;
@property (copy, nonatomic) void (^loginCompletionHandler)(BOOL success, NSError *error);
@property (strong, nonatomic) NSHTTPCookie *authCookie;

@end

@implementation ABAirbugManager

NSString * const ABAirbugManagerError = @"ABAirbugManagerError";
NSString * const AirbugCookieAPITokenKey = @"airbug.sid";

#pragma mark - Lifecycle

- (id)initWithCommunicator:(ABNetworkCommunicator *)communicator
       incomingDataBuilder:(ABIncomingDataBuilder *)incomingBuilder
       outgoingDataBuilder:(ABOutgoingDataBuilder *)outgoingBuilder
{
    if (self = [super init]) {
        _communicator = communicator;
        _incomingBuilder = incomingBuilder;
        _outgoingBuilder = outgoingBuilder;
        _authCookie = [self savedCookie];
        
        if (_authCookie) {
            NSLog(@"Found previous authentication cookie");
        } else {
            NSLog(@"No authentication cookie found");
        }
    }
    return self;
}

#pragma mark - Custom accessors

- (void)setDelegate:(id<ABAirbugManagerDelegate>)delegate {
    if (![delegate conformsToProtocol:@protocol(ABAirbugManagerDelegate)]) {
        [NSException raise:@"Unsupported delegate" format:@"Object must conform to protocol"];
    }
    
    // Set up the communicator with the various delegate notification messages
    __weak ABIncomingDataBuilder *weakIncomingBuilder = _incomingBuilder;
    __weak ABAirbugManager *weakSelf = self;
    self.communicator.receivedJSONObjectHandler = ^(id JSONObject)
    {
        id theDelegate = weakSelf.delegate;
        id parsedObject = [weakIncomingBuilder objectFromJSONDictionary:(NSDictionary *)JSONObject];
        
        if ([parsedObject isKindOfClass:[ABLoginResponse class]]) {
            ABLoginResponse *loginResponse = (ABLoginResponse *)parsedObject;
            
            if (loginResponse.success) {
                NSLog(@"Successfully logged in. Meld document: %@", loginResponse.meldDocument);
                if (weakSelf.loginCompletionHandler) weakSelf.loginCompletionHandler(YES, nil);
                return;
            }
            
            NSError *error = [NSError errorWithDomain:ABAirbugManagerError code:ABAirbugManagerCommunicationError userInfo:@{ NSLocalizedDescriptionKey : loginResponse.errorMessage }];
            if (weakSelf.loginCompletionHandler) weakSelf.loginCompletionHandler(NO, error);
            
        } else if ([parsedObject isKindOfClass:[NSUserNotification class]]) {
            if ([theDelegate respondsToSelector:@selector(didReceiveNotification:)]) {
                [theDelegate didReceiveNotification:parsedObject];
            }
        } else if ([parsedObject isKindOfClass:[ABWindowVisibilityRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(didReceiveWindowVisibilityRequest:)]) {
                ABWindowVisibilityRequest *request = (ABWindowVisibilityRequest *)parsedObject;
                [theDelegate didReceiveWindowVisibilityRequest:request.showWindow];
            }
        } else if ([parsedObject isKindOfClass:[ABWindowResizeRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(didReceiveWindowResizeRequest:)]) {
                ABWindowResizeRequest *request = (ABWindowResizeRequest *)parsedObject;
                [theDelegate didReceiveWindowResizeRequest:request.size];
            }
        } else if ([parsedObject isKindOfClass:[ABScreenshotRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(didReceiveWindowResizeRequest:)]) {
                ABScreenshotRequest *request = (ABScreenshotRequest *)parsedObject;
                [theDelegate didReceiveScreenshotRequest:request.type];
            }
        } else if ([parsedObject isKindOfClass:[ABBrowserRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(didReceiveOpenBrowserRequest:)]) {
                ABBrowserRequest *request = (ABBrowserRequest *)parsedObject;
                [theDelegate didReceiveOpenBrowserRequest:request.url];
            }
        }
    };
    _delegate = delegate;
}

- (BOOL)isLoggedIn
{
    return self.authCookie != nil;
}

#pragma mark - Public methods

- (void)logInWithUsername:(NSString *)username password:(NSString *)password onCompletion:(void(^)(BOOL success, NSError *error))completionHandler
{
    if ([self isLoggedIn]) {
        if (completionHandler) completionHandler(YES, nil);
        return;
    }
    
    NSDictionary *JSONRequest = [self.outgoingBuilder createLoginRequestForUsername:username password:password];
    self.loginCompletionHandler = completionHandler;
    BOOL success = [self.communicator sendJSONRequest:JSONRequest error:NULL];
    if (!success) completionHandler(NO, NULL);
}

- (void)logOut
{
    if (self.authCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.authCookie];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authCookie"];
        
        self.authCookie = nil;
    }
}

- (void)sendPreviewScreenshotRequestForImage:(NSImage *)image ofType:(ABScreenshotType)type {
    NSDictionary *JSONRequest = [self.outgoingBuilder createPreviewScreenshotRequestWithImage:image type:type];
    NSError *error;
    BOOL success = [self.communicator sendJSONRequest:JSONRequest error:&error];
    if (!success) {
        // TODO: Figure out how we should handle these errors
    }
}

#pragma mark - Private methods

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

@end
