//
//  ABAirbugLoginManager.m
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugLoginManager.h"

@implementation ABAirbugLoginManager

- (id)initWithCommunicator:(ABAirbugCommunicator *)communicator
{
    if (self = [super init]) {
        _communicator = communicator;
    }
    return self;
}

@end
