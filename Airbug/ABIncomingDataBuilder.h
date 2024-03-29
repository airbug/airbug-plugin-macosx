//
//  ABIncomingDataBuilder.h
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABIncomingDataBuilder : NSObject

/**
 Reads JSON dictionary and returns the image's URL. Returns nil if JSON is malformed or missing.
 @param JSONDictionary A JSON dictionary.
 */
- (NSURL *)imageURLFromJSONDictionary:(NSDictionary *)JSONDictionary;

/**
 Reads JSON dictionary and returns the video's URL. Returns nil if JSON is malformed or missing.
 @param JSONDictionary A JSON dictionary.
 */
- (NSURL *)videoURLFromJSONDictionary:(NSDictionary *)JSONDictionary;

/**
 Reads an incoming JSON message from the server and returns an object encapsulating that data.
 */
- (id)objectFromJSONDictionary:(NSDictionary *)JSONDictionary;

@end
