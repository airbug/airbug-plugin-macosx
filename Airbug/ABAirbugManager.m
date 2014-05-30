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
        
        __weak ABIncomingDataBuilder *weakObject = _incomingBuilder;
        __weak ABAirbugManager *weakManager = self;

        _communicator.receivedJSONObjectHandler = ^(id JSONObject) {
            id parsedObject = [weakObject objectFromJSONDictionary:(NSDictionary *)JSONObject];
            if ([parsedObject isKindOfClass:[NSUserNotification class]]) {
                if (weakManager.notificationHandler) {
                    weakManager.notificationHandler(parsedObject);
                }
            } else if ([parsedObject isKindOfClass:[ABWindowVisibilityRequest class]]) {
                ABWindowVisibilityRequest *request = (ABWindowVisibilityRequest *)parsedObject;
                
                if (weakManager.windowVisibilityRequestHandler) {
                    weakManager.windowVisibilityRequestHandler(request.showWindow);
                }
            } else if ([parsedObject isKindOfClass:[ABWindowResizeRequest class]]) {
                ABWindowResizeRequest *request = (ABWindowResizeRequest *)parsedObject;
                
                if (weakManager.windowResizeRequestHandler) {
                    weakManager.windowResizeRequestHandler(request.size);
                }
            } else if ([parsedObject isKindOfClass:[ABLoginResponse class]]) {
                ABLoginResponse *loginResponse = (ABLoginResponse *)parsedObject;
                
                if (loginResponse.success) {
                    NSLog(@"Successfully logged in. Meld document: %@", loginResponse.meldDocument);
                    
                    if (weakManager.loginCompletionHandler) {
                        weakManager.loginCompletionHandler(YES, nil);
                    }
                } else if (!loginResponse.success) {
                    NSLog(@"Failed to log in: %@", loginResponse.errorMessage);
                    NSError *error = [NSError errorWithDomain:ABAirbugManagerError code:ABAirbugManagerCommunicationError userInfo:@{ NSLocalizedDescriptionKey : loginResponse.errorMessage }];

                    if (weakManager.loginCompletionHandler) {
                        weakManager.loginCompletionHandler(NO, error);
                    }
                }
            } else if ([parsedObject isKindOfClass:[ABScreenshotRequest class]]) {
                ABScreenshotRequest *request = (ABScreenshotRequest *)parsedObject;
                
                if (weakManager.screenshotRequestHandler) {
                    weakManager.screenshotRequestHandler(request.type);
                }
            }
        };
        
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

- (BOOL)isLoggedIn
{
    return self.authCookie != nil;
}

#pragma mark - Public methods

- (void)uploadPNGImageData:(NSData *)imageData onCompletion:(void (^)(NSURL *, NSError *))completionHandler
{
    NSDictionary *parameters = [self.outgoingBuilder parametersForPNGImage:imageData];
    [self.communicator sendPNGImageData:imageData withParameters:parameters onCompletion:^(NSDictionary *jsonDictionary, NSError *communicatorError) {
        if (communicatorError) {
            NSString *errorMessage = [NSString stringWithFormat:@"Failed to communicate with server. Check network connection and try again."];
            NSError *error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                        code:ABAirbugManagerCommunicationError
                                                    userInfo:@{NSUnderlyingErrorKey : communicatorError,
                                                               NSLocalizedDescriptionKey : errorMessage}];
            completionHandler(nil, error);
        } else {
            NSURL *url = [self.incomingBuilder imageURLFromJSONDictionary:jsonDictionary];
            NSError *error;
            if (!url) {
                NSString *errorMessage = [NSString stringWithFormat:@"Malformed or missing JSON response from server"];
                error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                   code:ABAirbugManagerDataError
                                               userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                NSLog(@"Malformed or missing JSON: %@", jsonDictionary);
            }
            completionHandler(url, error);
        }
    }];
}

- (void)uploadQuickTimeVideoFile:(NSURL *)fileURL progress:(NSProgress **)progress onCompletion:(void (^)(NSURL *, NSError *))completionHandler
{
    NSDictionary *parameters = [self.outgoingBuilder parametersForQuickTimeVideo:fileURL];
    [self.communicator sendQuickTimeVideoFile:fileURL withParameters:parameters progress:progress onCompletion:^(NSDictionary *jsonDictionary, NSError *communicatorError)
    {
        if (communicatorError) {
            NSString *errorMessage = [NSString stringWithFormat:@"Failed to communicate with server. Check network connection and try again."];
            NSError *error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                        code:ABAirbugManagerCommunicationError
                                                    userInfo:@{NSUnderlyingErrorKey : communicatorError,
                                                               NSLocalizedDescriptionKey : errorMessage}];
            completionHandler(nil, error);
        } else {
            NSURL *url = [self.incomingBuilder videoURLFromJSONDictionary:jsonDictionary];
            NSError *error;
            if (!url) {
                NSString *errorMessage = [NSString stringWithFormat:@"Malformed or missing JSON response from server"];
                error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                   code:ABAirbugManagerDataError
                                               userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                NSLog(@"Malformed or missing JSON: %@", jsonDictionary);
            }
            completionHandler(url, error);
        }
    }];
}

- (void)logInWithUsername:(NSString *)username password:(NSString *)password onCompletion:(void(^)(BOOL success, NSError *error))completionHandler
{
    if ([self isLoggedIn]) {
        if (completionHandler) completionHandler(YES, nil);
        return;
    }
    
    NSDictionary *JSONRequest = [self.outgoingBuilder JSONLoginRequestForUsername:username password:password];
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
