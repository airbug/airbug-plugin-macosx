//
//  ABConnectionStateNotice.h
//  Airbug
//
//  Created by Richard Shin on 6/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ABConnectionState) {
    ABConnectionStateUnknown = 0,
    ABConnectionStateConnected = 1,
    ABConnectionStateConnecting,
    ABConnectionStateDisconnected
};

@interface ABConnectionStateNotice : NSObject

@property (nonatomic) ABConnectionState connectionState;

+ (ABConnectionState)typeForConnectionState:(NSString *)connectionState;
+ (NSString *)stringForConnectionState:(ABConnectionState)connectionState;

@end
