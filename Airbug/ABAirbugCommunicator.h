//
//  ABAirbugCommunicator.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class ABAirbugCommunicator
 @description Handles network communication with Airbug backend servers.
 @dependency Dependency on SocketRocket, an open-source library for handling WebSockets in Objective-C.
*/

@interface ABAirbugCommunicator : NSObject

/**
 Upload image data to the image endpoint.
 @param imageData Image data to upload. Cannot be nil. Having it be NSData allows
 */
- (void)sendImageData:(NSData *)imageData onCompletion:(void (^)(NSData *, NSError *))completionHandler;

@end
