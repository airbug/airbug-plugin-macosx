//
//  ABFileSystemManager.h
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABFileSystemManager : NSObject

/**
 Array of @c NSURL objects, one for each directory on the local file system to allow
 the server to access. For now, it is assumed that allowing access to one root directory
 will recursively allow access to its child directories.
 */
- (NSArray *)availableDirectories;

/**
 Array of @c NSURL objects, one for each directory on the local file system to allow
 the server to access. Throws an exception if an invalid NSURL is specified.
 */
- (void)setAvailableDirectories:(NSArray *)availableDirectories;

@end
