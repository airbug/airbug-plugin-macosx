//
//  ABAuthenticationNotice.m
//  Airbug
//
//  Created by Richard Shin on 6/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAuthenticationNotice.h"

@implementation ABAuthenticationNotice

+ (NSString *)stringForAuthenticationState:(ABAuthenticationState)authenticationState {
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @(ABAuthenticationStateLoggedIn) : @"loggedIn",
                  @(ABAuthenticationStateLoggedOut) : @"loggedOut",
                  };
    }
    if (![[types allKeys] containsObject:@(authenticationState)]) {
        return @"Unknown";
    }
    return types[@(authenticationState)];
    
}

+ (ABAuthenticationState)typeForAuthenticationState:(NSString *)authenticationState {
    static NSDictionary *types;
    if (!types) {
        types = @{
                  @"loggedIn" : @(ABAuthenticationStateLoggedIn),
                  @"loggedOut" : @(ABAuthenticationStateLoggedOut),
                  };
    }
    if (![[types allKeys] containsObject:authenticationState]) {
        return ABAuthenticationStateUnknown;
    }
    return [types[authenticationState] integerValue];
}

@end
