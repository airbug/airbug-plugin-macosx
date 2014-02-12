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
    NSDictionary *parameters = [self.outgoingBuilder parametersForImage:imageData];
    [self.communicator sendPNGImageData:imageData withParameters:parameters onCompletion:^(NSDictionary *jsonDictionary, NSError *communicatorError) {
        if (communicatorError) {
            NSString *errorMessage = [NSString stringWithFormat:@"Failed to communicate with server. Check network connection and try again."];
            NSError *error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                        code:ABAirbugManagerCommunicationError
                                                    userInfo:@{NSUnderlyingErrorKey : communicatorError,
                                                               NSLocalizedDescriptionKey : errorMessage}];
            completionHandler(nil, error);
        } else {
            NSURL *url = [self.incomingBuilder imageURLFromJSONDictionary:jsonDictionary];
            NSError *error;
            if (!url) {
                NSString *errorMessage = [NSString stringWithFormat:@"Malformed or missing JSON response from server"];
                error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                   code:ABAirbugManagerDataError
                                               userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                NSLog(@"Malformed or missing JSON: %@", jsonDictionary);
            }
            completionHandler(url, error);
        }
    }];
}

@end
