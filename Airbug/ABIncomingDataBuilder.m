//
//  ABIncomingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABIncomingDataBuilder.h"

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


@end
