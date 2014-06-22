//
//  ABIncomingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABIncomingDataBuilder.h"
#import "ABLoginResponse.h"
#import "ABWindowVisibilityRequest.h"
#import "ABWindowResizeRequest.h"
#import "ABScreenshotRequest.h"
#import "ABBrowserRequest.h"
#import "ABSaveCookieRequest.h"
#import "ABRestoreCookieRequest.h"
#import "ABAuthenticationNotice.h"
#import "ABUser.h"
#import "ABConnectionStateNotice.h"
#import "ABAvailableDirectoriesRequest.h"
#import "ABListDirectoryContentsRequest.h"

@implementation ABIncomingDataBuilder

NSString * const ImageURLKeyPath = @"url";
NSString * const VideoURLKeyPath = @"url";

- (NSURL *)imageURLFromJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSString *imageURL = [JSONDictionary valueForKeyPath:ImageURLKeyPath];
    return [NSURL URLWithString:imageURL];
}

- (NSURL *)videoURLFromJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSString *imageURL = JSONDictionary[VideoURLKeyPath];
    return [NSURL URLWithString:imageURL];
}

- (id)objectFromJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSString *type = JSONDictionary[@"type"];
    
    if ([type isEqualToString:@"UserNotification"]) {
        NSUserNotification *notification = [NSUserNotification new];
        notification.title = [JSONDictionary valueForKeyPath:@"data.title"];
        notification.subtitle = [JSONDictionary valueForKeyPath:@"data.subtitle"];
        notification.informativeText = [JSONDictionary valueForKeyPath:@"data.informativeText"];
        // TODO: will there ever be a forward delivery date? Not right now I don't think... just display it now.
        notification.deliveryDate = [NSDate date];
        notification.userInfo = [JSONDictionary valueForKeyPath:@"data.userInfo"];
        return notification;
    }
    
    if ([type isEqualToString:@"LoginSuccess"]) {
        ABLoginResponse *loginResponse = [[ABLoginResponse alloc] init];
        loginResponse.success = YES;
        loginResponse.meldDocument = JSONDictionary[@"data"];
        return loginResponse;
    }
    
    if ([type isEqualToString:@"LoginError"]) {
        ABLoginResponse *loginResponse = [[ABLoginResponse alloc] init];
        loginResponse.success = NO;
        loginResponse.errorMessage = JSONDictionary[@"data"];
        return loginResponse;
    }
    
    if ([type isEqualToString:@"ShowWindow"] || [type isEqualToString:@"HideWindow"]) {
        ABWindowVisibilityRequest *request = [[ABWindowVisibilityRequest alloc] init];
        request.showWindow = [type isEqualToString:@"ShowWindow"];
        return request;
    }
    
    if ([type isEqualToString:@"ResizeWindow"]) {
        ABWindowResizeRequest *request = [[ABWindowResizeRequest alloc] init];
        CGFloat width = [[JSONDictionary valueForKeyPath:@"data.width"] floatValue];
        CGFloat height = [[JSONDictionary valueForKeyPath:@"data.height"] floatValue];
        request.size = NSMakeSize(width, height);
        return request;
    }
    
    if ([type isEqualToString:@"TakeScreenshot"]) {
        ABScreenshotRequest *request = [[ABScreenshotRequest alloc] init];
        NSString *screenshotType = [JSONDictionary valueForKeyPath:@"data.type"];
        ABScreenshotType type = [ABScreenshotRequest typeFromString:screenshotType];
        request.type = type;
        return request;
    }
    
    if ([type isEqualToString:@"OpenBrowser"]) {
        ABBrowserRequest *request = [[ABBrowserRequest alloc] init];
        NSString *url = [JSONDictionary valueForKeyPath:@"data.url"];
        request.url = [NSURL URLWithString:url];
        return request;
    }
    
    if ([type isEqualToString:@"SaveCookie"]) {
        ABSaveCookieRequest *request = [[ABSaveCookieRequest alloc] init];
        request.cookieName = [JSONDictionary valueForKeyPath:@"data.cookieName"];
        return request;
    }
    
    if ([type isEqualToString:@"RestoreCookie"]) {
        ABRestoreCookieRequest *request = [[ABRestoreCookieRequest alloc] init];
        request.cookieName = [JSONDictionary valueForKeyPath:@"data.cookieName"];
        request.messageID = [JSONDictionary valueForKeyPath:@"messageId"];
        return request;
    }
    
    if ([type isEqualToString:@"AuthStateChange"]) {
        ABAuthenticationNotice *notice = [[ABAuthenticationNotice alloc] init];
        NSString *authenticationStateString = [JSONDictionary valueForKeyPath:@"data.authState"];
        notice.authenticationState = [ABAuthenticationNotice typeForAuthenticationState:authenticationStateString];
        if (notice.authenticationState == ABAuthenticationStateLoggedIn) {
            notice.currentUser = [[ABUser alloc] init];
            notice.currentUser.firstName = [JSONDictionary valueForKeyPath:@"data.currentUser.firstName"];
            notice.currentUser.lastName = [JSONDictionary valueForKeyPath:@"data.currentUser.lastName"];
            notice.currentUser.email = [JSONDictionary valueForKeyPath:@"data.currentUser.email"];
            notice.currentUser.identifier = [JSONDictionary valueForKeyPath:@"data.currentUser.id"];
        }
        return notice;
    }
    
    if ([type isEqualToString:@"ConnectionStateChange"]) {
        ABConnectionStateNotice *notice = [[ABConnectionStateNotice alloc] init];
        NSString *connectionStateString = [JSONDictionary valueForKeyPath:@"data.connectionState"];
        notice.connectionState = [ABConnectionStateNotice typeForConnectionState:connectionStateString];
        return notice;
    }
    
    if ([type isEqualToString:@"GetAvailableDirectories"]) {
        ABAvailableDirectoriesRequest *request = [[ABAvailableDirectoriesRequest alloc] init];
        return request;
    }
    
    if ([type isEqualToString:@"ListDirectoryContents"]) {
        ABListDirectoryContentsRequest *request = [[ABListDirectoryContentsRequest alloc] init];
        request.directory = [JSONDictionary valueForKeyPath:@"data.directory"];
        request.showHiddenFiles = [[JSONDictionary valueForKeyPath:@"data.showHiddenFiles"] boolValue];
        return request;
    }
    
    if ([type isEqualToString:@"MessageError"]) {
        // TODO: return something more appropriate
        return nil;
    }
    
    return nil;
}

@end
