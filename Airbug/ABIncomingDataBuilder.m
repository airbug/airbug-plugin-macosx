//
//  ABIncomingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABIncomingDataBuilder.h"

@implementation ABIncomingDataBuilder

NSString * const ImageURLKey = @"url";

- (NSURL *)imageURLFromJSONDictionary:(NSDictionary *)JSONDictionary
{
    NSString *imageURL = JSONDictionary[ImageURLKey];
    return [NSURL URLWithString:imageURL];
}

@end
