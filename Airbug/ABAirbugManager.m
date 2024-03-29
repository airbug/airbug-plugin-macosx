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
#import "ABSaveCookieRequest.h"
#import "ABRestoreCookieRequest.h"
#import "ABAuthenticationNotice.h"
#import "ABAvailableDirectoriesRequest.h"
#import "ABListDirectoryContentsRequest.h"
#import "ABAddFavoriteDirectoryRequest.h"
#import "ABStreamFileRequest.h"

@interface ABAirbugManager ()

@property (strong, nonatomic) ABNetworkCommunicator *communicator;
@property (strong, nonatomic) ABIncomingDataBuilder *incomingBuilder;
@property (strong, nonatomic) ABOutgoingDataBuilder *outgoingBuilder;
@property (strong, nonatomic) NSHTTPCookie *authCookie;

@end

@implementation ABAirbugManager

NSString * const ABAirbugManagerError = @"ABAirbugManagerError";

#pragma mark - Lifecycle

- (id)initWithCommunicator:(ABNetworkCommunicator *)communicator
       incomingDataBuilder:(ABIncomingDataBuilder *)incomingBuilder
       outgoingDataBuilder:(ABOutgoingDataBuilder *)outgoingBuilder
{
    if (self = [super init]) {
        _communicator = communicator;
        _incomingBuilder = incomingBuilder;
        _outgoingBuilder = outgoingBuilder;
        // RSS: may be unnecessary, since client plugin JS should send us a message to restore
        // a login cookie
        [self saveOrRestoreLoginCookieWithName:@"airbug.sid"];
        
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
                // Note: we now notify the delegate about successful login by waiting for the
                // ABAuthenticationNotice message to be sent to us.
            } else {
                NSError *error = [NSError errorWithDomain:ABAirbugManagerError code:ABAirbugManagerCommunicationError userInfo:@{ NSLocalizedDescriptionKey : loginResponse.errorMessage }];
                if ([theDelegate respondsToSelector:@selector(manager:loginFailedWithError:)]) {
                    [theDelegate manager:weakSelf loginFailedWithError:error];
                }
            }
        } else if ([parsedObject isKindOfClass:[NSUserNotification class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveNotification:)]) {
                [theDelegate manager:weakSelf didReceiveNotification:parsedObject];
            }
        } else if ([parsedObject isKindOfClass:[ABWindowVisibilityRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveWindowVisibilityRequest:)]) {
                ABWindowVisibilityRequest *request = (ABWindowVisibilityRequest *)parsedObject;
                [theDelegate manager:weakSelf didReceiveWindowVisibilityRequest:request.showWindow];
            }
        } else if ([parsedObject isKindOfClass:[ABWindowResizeRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveWindowResizeRequest:)]) {
                ABWindowResizeRequest *request = (ABWindowResizeRequest *)parsedObject;
                [theDelegate manager:weakSelf didReceiveWindowResizeRequest:request.size];
            }
        } else if ([parsedObject isKindOfClass:[ABScreenshotRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveWindowResizeRequest:)]) {
                ABScreenshotRequest *request = (ABScreenshotRequest *)parsedObject;
                [theDelegate manager:weakSelf didReceiveScreenshotRequest:request.type];
            }
        } else if ([parsedObject isKindOfClass:[ABBrowserRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveOpenBrowserRequest:)]) {
                ABBrowserRequest *request = (ABBrowserRequest *)parsedObject;
                [theDelegate manager:weakSelf didReceiveOpenBrowserRequest:request.url];
            }
        } else if ([parsedObject isKindOfClass:[ABSaveCookieRequest class]]) {
            ABSaveCookieRequest *request = (ABSaveCookieRequest *)parsedObject;
            BOOL success = [weakSelf saveOrRestoreLoginCookieWithName:request.cookieName];
            NSLog(@"%@ cookie named %@", success ? @"Saved" : @"Failed to save", request.cookieName);
        } else if ([parsedObject isKindOfClass:[ABRestoreCookieRequest class]]) {
            ABRestoreCookieRequest *request = (ABRestoreCookieRequest *)parsedObject;
            
            BOOL success = [weakSelf saveOrRestoreLoginCookieWithName:request.cookieName];
            NSLog(@"%@ cookie named %@", success ? @"Restored" : @"Failed to restore", request.cookieName);
            
            ABResponseStatus responseStatus = success ? ABResponseStatusSuccess : ABResponseStatusError;
            NSDictionary *response = [weakSelf.outgoingBuilder createRestoreCookieResponseForMessageID:request.messageID status:responseStatus];
            [weakSelf sendJSONObject:response];
        } else if ([parsedObject isKindOfClass:[ABAuthenticationNotice class]]) {
            ABAuthenticationNotice *notice = (ABAuthenticationNotice *)parsedObject;
            if (notice.authenticationState == ABAuthenticationStateLoggedIn) {
                if ([theDelegate respondsToSelector:@selector(manager:didLogInSuccessfullyWithUser:)]) {
                    [theDelegate manager:weakSelf didLogInSuccessfullyWithUser:notice.currentUser];
                }
            } else if (notice.authenticationState == ABAuthenticationStateLoggedOut) {
                if ([theDelegate respondsToSelector:@selector(managerDidLogOutSuccessfully:)]) {
                    [theDelegate managerDidLogOutSuccessfully:weakSelf];
                }
            }
        } else if ([parsedObject isKindOfClass:[ABConnectionStateNotice class]]) {
            ABConnectionStateNotice *notice = (ABConnectionStateNotice *)parsedObject;
            if ([theDelegate respondsToSelector:@selector(manager:connectionStateChanged:)]) {
                [theDelegate manager:weakSelf connectionStateChanged:notice.connectionState];
            }
        } else if ([parsedObject isKindOfClass:[ABAvailableDirectoriesRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(managerDidReceiveAvailableDirectoriesRequest:)]) {
                [theDelegate managerDidReceiveAvailableDirectoriesRequest:weakSelf];
            }
        } else if ([parsedObject isKindOfClass:[ABListDirectoryContentsRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveListDirectoryContentsRequest:)]) {
                [theDelegate manager:weakSelf didReceiveListDirectoryContentsRequest:parsedObject];
            }
        } else if ([parsedObject isKindOfClass:[ABAddFavoriteDirectoryRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveAddFavoriteDirectoryRequest:)]) {
                [theDelegate manager:weakSelf didReceiveAddFavoriteDirectoryRequest:parsedObject];
            }
        } else if ([parsedObject isKindOfClass:[ABStreamFileRequest class]]) {
            if ([theDelegate respondsToSelector:@selector(manager:didReceiveStreamFileRequest:)]) {
                [theDelegate manager:weakSelf didReceiveStreamFileRequest:parsedObject];
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

- (void)sendShowLoginPageRequest
{
    NSDictionary *JSONRequest = [self.outgoingBuilder createShowLoginPageRequest];
    [self sendJSONObject:JSONRequest];
}

- (void)logOut
{
    if (self.authCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.authCookie];
        self.authCookie = nil;
        NSDictionary *JSONRequest = [self.outgoingBuilder createLogoutRequest];
        [self sendJSONObject:JSONRequest];
    }
}

- (void)sendPreviewScreenshotRequestForImage:(NSImage *)image ofType:(ABScreenshotType)type {
    NSDictionary *JSONRequest = [self.outgoingBuilder createPreviewScreenshotRequestWithImage:image type:type];
    [self sendJSONObject:JSONRequest];
}

- (void)sendTryConnectRequest {
    NSDictionary *JSONRequest = [self.outgoingBuilder createTryConnectRequest];
    [self sendJSONObject:JSONRequest];
}

- (void)sendAvailableDirectories:(NSArray *)availableDirectories
{
    NSDictionary *JSONResponse = [self.outgoingBuilder createAvailableDirectoriesResponse:availableDirectories];
    [self sendJSONObject:JSONResponse];
}

- (void)sendDirectoryContents:(ABDirectoryContents *)contents
{
    NSDictionary *JSONResponse = [self.outgoingBuilder createDirectoryContentsResponse:contents];
    [self sendJSONObject:JSONResponse];
}

- (void)sendStreamFileResponse:(ABStreamFileResponse *)response
{
    NSDictionary *JSONResponse = [self.outgoingBuilder createStreamFileResponse:response];
    [self sendJSONObject:JSONResponse];
}

- (void)sendData:(NSData *)data forStream:(NSString *)streamID
{
    if (data) {
        [self.communicator sendData:data forStream:streamID];
    }
}

- (void)closeStream:(NSString *)streamID
{
    [self.communicator closeStream:streamID];
}

#pragma mark - Private methods

- (void)sendJSONObject:(id)JSONObject {
    NSError *error;
    BOOL success = [self.communicator sendJSONObject:JSONObject error:&error];
    if (!success) {
        if ([self.delegate respondsToSelector:@selector(manager:failedToSendJSONObject:error:)]) {
            [self.delegate manager:self failedToSendJSONObject:JSONObject error:error];
        }
    }
}

- (BOOL)saveOrRestoreLoginCookieWithName:(NSString *)cookieName
{
    NSURL *url = [NSURL URLWithString:AirbugAPIBridgeURL];
    NSString *domain = [url host];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([[cookie domain] isEqualToString:domain] &&
            [[cookie name] isEqualToString:cookieName])
        {
            NSLog(@"Cookie: %@", [cookie value]);
            self.authCookie = cookie;
            return YES;
        }
    }
    return NO;
}

@end
