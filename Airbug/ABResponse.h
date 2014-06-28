//
//  ABResponse.h
//  Airbug
//
//  Created by Richard Shin on 6/28/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ABResponseStatus) {
    ABResponseStatusUnknown = 0,
    ABResponseStatusSuccess,
    ABResponseStatusError
};

/**
 @class An abstract class that forms the general request-response message between the server
 and the client. Requests are associated with a message ID, and responses send back the message
 ID as a response ID.
 */

@interface ABResponse : NSObject

@property (strong, nonatomic) NSString *responseID;

@property (nonatomic) ABResponseStatus responseStatus;

@end
