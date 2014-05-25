//
//  ABOutgoingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABOutgoingDataBuilder.h"

@implementation ABOutgoingDataBuilder

- (NSDictionary *)parametersForPNGImage:(NSData *)imageData
{
    // Returns empty dictionary for now -- no parameters
    return @{};
}

- (NSDictionary *)parametersForQuickTimeVideo:(NSURL *)fileURL {
    return @{};
}

- (NSDictionary *)JSONLoginRequestForUsername:(NSString *)username password:(NSString *)password
{
    return @{
             @"type" : @"LoginRequest",
             @"data" : @{
                         @"username" : username,
                         @"password" : password
                         }
             };
}

@end
