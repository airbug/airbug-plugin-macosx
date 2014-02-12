//
//  ABAirbugManager.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugManager.h"

@interface ABAirbugManager ()
@property (strong, nonatomic) ABAirbugCommunicator *communicator;
@property (strong, nonatomic) ABIncomingDataBuilder *incomingBuilder;
@property (strong, nonatomic) ABOutgoingDataBuilder *outgoingBuilder;
@end

@implementation ABAirbugManager

NSString * const ABAirbugManagerError = @"ABAirbugManagerError";

- (id)initWithCommunicator:(ABAirbugCommunicator *)communicator
       incomingDataBuilder:(ABIncomingDataBuilder *)incomingBuilder
       outgoingDataBuilder:(ABOutgoingDataBuilder *)outgoingBuilder
{
    if (self = [super init]) {
        _communicator = communicator;
        _incomingBuilder = incomingBuilder;
        _outgoingBuilder = outgoingBuilder;
    }
    return self;
}

- (void)uploadPNGImageData:(NSData *)imageData onCompletion:(void (^)(NSURL *, NSError *))completionHandler
{
    [self.communicator sendPNGImageData:imageData onCompletion:^(NSDictionary *jsonDictionary, NSError *communicatorError) {
        if (communicatorError) {
            NSError *error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                        code:ABAirbugManagerCommunicationError
                                                    userInfo:@{NSUnderlyingErrorKey : communicatorError}];
            completionHandler(nil, error);
        } else {
            NSURL *url = [self.incomingBuilder imageURLFromJSONDictionary:jsonDictionary];
            completionHandler(url, nil);
        }
    }];
}

@end
