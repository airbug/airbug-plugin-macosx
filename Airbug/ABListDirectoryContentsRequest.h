//
//  ABListDirectoryRequest.h
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABRequest.h"

@interface ABListDirectoryContentsRequest : ABRequest

@property (strong, nonatomic) NSString *directory;

@property (nonatomic) BOOL showHiddenFiles;

@end
