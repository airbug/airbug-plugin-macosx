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

extern NSString *const ABAirbugCommunicatorError;

/**
 Upload image data to the image endpoint.
 @param imageData PNG image data to upload. Cannot be nil.
 @param parameters Parameters to be encoded and sent to the server
 @param completionHandler On success, returns JSON server response as an NSDictionary. NSError is nil if no error
 */
- (void)sendPNGImageData:(NSData *)imageData withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler;

@end
