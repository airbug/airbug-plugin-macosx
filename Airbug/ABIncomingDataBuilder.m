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
    
    if ([type isEqualToString:@"MessageError"]) {
        // TODO: return something more appropriate
        return nil;
    }
    
    return nil;
}

@end
