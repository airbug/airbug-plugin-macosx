//
//  ABStreamFileRequest.h
//  Airbug
//
//  Created by Richard Shin on 7/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABRequest.h"

@interface ABStreamFileRequest : ABRequest

@property (strong, nonatomic) NSString *streamId;
@property (strong, nonatomic) NSString *filePath;
@property (nonatomic) NSInteger chunkSize;

@end
