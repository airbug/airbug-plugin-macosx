//
//  ABAirbugLoginManager.h
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAirbugCommunicator.h"

@interface ABAirbugLoginManager : NSObject

- (id)initWithCommunicator:(ABAirbugCommunicator *)communicator;

@property (strong, nonatomic) ABAirbugCommunicator *communicator;

@end
