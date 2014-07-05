//
//  ABStreamFileResponse.h
//  Airbug
//
//  Created by Richard Shin on 7/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABResponse.h"

typedef NS_ENUM(NSUInteger, ABStreamFileStatus) {
    ABStreamFileStatusUnknown = 0,
    ABStreamFileStatusSuccess,
    ABStreamFileStatusAccessDenied,
    ABStreamFileStatusNotAFile,
    ABStreamFileStatusNotFound
};

@interface ABStreamFileResponse : ABResponse

@property (nonatomic) ABStreamFileStatus streamFileStatus;

@end
