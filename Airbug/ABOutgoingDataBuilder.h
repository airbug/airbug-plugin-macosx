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
 Creates a JSON object that represents a login request.
 */
- (NSDictionary *)createLoginRequestForUsername:(NSString *)username password:(NSString *)password;

/**
 Creates a JSON object that represents a preview screenshot request.
 */
- (NSDictionary *)createPreviewScreenshotRequestWithImage:(NSImage *)image type:(ABScreenshotType)type;


@end
