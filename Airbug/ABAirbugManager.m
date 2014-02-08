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

// TODO: For now, I'm assuming that the data we're interested in after uploading an image is the URL of the image.
// Will we be receiving anything else interesting? If so, we may want to wrap the URL and this add'l data into
// a model class and have that be a completion handler block parameter.
- (void)uploadImageData:(NSData *)imageData onCompletion:(void (^)(NSURL *, NSError *))completionHandler
{
    [self.communicator sendImageData:imageData onCompletion:^(NSData *data, NSError *communicatorError) {
        if (communicatorError) {
            NSLog(@"Error from communicator: %@", [communicatorError localizedDescription]);
            NSError *error = [[NSError alloc] initWithDomain:ABAirbugManagerError
                                                        code:ABAirbugManagerCommunicationError
                                                    userInfo:@{NSUnderlyingErrorKey : communicatorError}];
            completionHandler(nil, error);
        } else {
            // TODO: send data to incomingDataBuilder... something like:
            // NSURL *url = [self.incomingBuilder URLFromData:data];
            NSURL *url = [NSURL URLWithString:@"stub URL"];
            completionHandler(url, nil);
        }
    }];
}

@end
