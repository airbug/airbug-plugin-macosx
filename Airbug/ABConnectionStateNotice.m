//
//  ABConnectionStateNotice.m
//  Airbug
//
//  Created by Richard Shin on 6/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABConnectionStateNotice.h"

@implementation ABConnectionStateNotice

+ (ABConnectionState)typeForConnectionState:(NSString *)connectionState
{
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @"connected" : @(ABConnectionStateConnected),
                  @"connecting" : @(ABConnectionStateConnecting),
                  @"disconnected" : @(ABConnectionStateDisconnected)
                  };
    }
    if (![[types allKeys] containsObject:connectionState]) {
        return ABConnectionStateUnknown;
    }
    return [types[connectionState] integerValue];
}

+ (NSString *)stringForConnectionState:(ABConnectionState)connectionState
{
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @(ABConnectionStateConnected) : @"connected",
                  @(ABConnectionStateConnecting) : @"connecting",
                  @(ABConnectionStateDisconnected) : @"disconnected"
                  };
    }
    if (![[types allKeys] containsObject:@(connectionState)]) {
        return @"Unknown";
    }
    return types[@(connectionState)];
}

@end
