//
//  ABVideoavUploadWindowController.h
//  Airbug
//
//  Created by Richard Shin on 3/2/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import "ABUploadWindowController.h"

@interface ABVideoUploadWindowController : ABUploadWindowController

@property (strong, nonatomic) AVPlayer *player;

@end
