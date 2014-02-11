//
//  ABAirbugCommunicator.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugCommunicator.h"

@implementation ABAirbugCommunicator

// TODO: With WebSockets, is it an endpoint URL? There are different endpoint URLs?
// We want to build the communicator to be responsible for handling communication to and from the server, so I may
// want to build this class to support a few different endpoints and use this in iOS as well.
- (void)sendImageData:(NSData *)imageData onCompletion:(void (^)(NSData *, NSError *))completionHandler
{
    // TODO: Do something with WebSockets
    completionHandler([NSData data], nil);
}

@end
