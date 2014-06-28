//
//  ABRequest.h
//  Airbug
//
//  Created by Richard Shin on 6/28/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class An abstract class that forms the general request-response message between the server
 and the client. Requests are associated with a message ID, and responses send back the message
 ID as a response ID.
 */

@interface ABRequest : NSObject

@property (strong, nonatomic) NSString *messageID;

@end
