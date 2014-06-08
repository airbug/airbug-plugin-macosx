//
//  ABAuthenticationNotice.h
//  Airbug
//
//  Created by Richard Shin on 6/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABUser.h"

typedef NS_ENUM(NSUInteger, ABAuthenticationState) {
    ABAuthenticationStateUnknown = 0,
    ABAuthenticationStateLoggedIn = 1,
    ABAuthenticationStateLoggedOut
};

@interface ABAuthenticationNotice : NSObject

@property (nonatomic) ABAuthenticationState authenticationState;
@property (strong, nonatomic) ABUser *currentUser;

+ (NSString *)stringForAuthenticationState:(ABAuthenticationState)authenticationState;
+ (ABAuthenticationState)typeForAuthenticationState:(NSString *)authenticationState;

@end
