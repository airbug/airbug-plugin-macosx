//
//  ABAirbugLoginWindowController.h
//  Airbug
//
//  Created by Richard Shin on 3/9/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "ABAirbugLoginManager.h"

@interface ABAirbugLoginWindowController : NSWindowController

- (id)initWithManager:(ABAirbugLoginManager *)manager;

@property (strong, nonatomic) ABAirbugLoginManager *manager;


@end
