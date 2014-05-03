//
//  ABLoginWindowController.h
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABAirbugCommunicator.h"

@interface ABLoginWindowController : NSWindowController

- (id)initWithCommunicator:(ABAirbugCommunicator *)communicator;

@property (strong, nonatomic) ABAirbugCommunicator *communicator;

@property (copy, nonatomic) void (^onSuccessfulLogin)();

@end
