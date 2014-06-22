//
//  ABOutgoingDataBuilder.h
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABScreenshotRequest.h"

@interface ABOutgoingDataBuilder : NSObject

/**
 Creates a JSON object that represents a preview screenshot request.
 */
- (NSDictionary *)createPreviewScreenshotRequestWithImage:(NSImage *)image type:(ABScreenshotType)type;

/**
 Creates a JSON object to send back to the server in response to a restore cookie request
 */
- (NSDictionary *)createRestoreCookieResponseForMessageID:(NSString *)messageID;

- (NSDictionary *)createShowLoginPageRequest;

- (NSDictionary *)createLogoutRequest;

- (NSDictionary *)createTryConnectRequest;

/**
 Creates a JSON object containing a list of directories
 @param availableDirectories Array of @c NSString objects containing the absolute path to
 directories on the local file system
 */
- (NSDictionary *)createAvailableDirectoriesResponse:(NSArray *)availableDirectories;

@end
