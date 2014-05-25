//
//  ABLoginWindowController.h
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABAirbugManager.h"

@interface ABLoginWindowController : NSWindowController

- (id)initWithManager:(ABAirbugManager *)manager;

@property (strong, nonatomic) ABAirbugManager *manager;

@property (copy, nonatomic) void (^onSuccessfulLogin)();

@end
