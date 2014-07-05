//
//  ABFileSystemManager.h
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABDirectoryContents;
@class ABStreamFileResponse;
@class ABFileStream;

@interface ABFileSystemManager : NSObject

/**
 Array of @c NSString objects, one for each directory on the local file system to allow
 the server to access. For now, it is assumed that allowing access to one root directory
 will recursively allow access to its child directories.
 */
- (NSArray *)availableDirectories;

/**
 Array of @c NSString objects, one for each directory on the local file system to allow
 the server to access. Throws an exception if an invalid NSURL is specified.
 */
- (void)setAvailableDirectories:(NSArray *)availableDirectories;

/**
 Returns the contents of a directory. If the contents of the directory cannot be returned,
 the @c ABDirectoryContents object contains information on why.
 @param directory Absolute path to the directory
 @param showHiddenFiles Flag that toggles whether to include hidden files
 */
- (ABDirectoryContents *)contentsOfDirectory:(NSString *)directory showHiddenFiles:(BOOL)showHiddenFiles;

/**
 Adds a directory to the list of available directories.
 @param directory The full path to the directory
 */
- (void)addDirectoryToAvailableDirectories:(NSString *)directory;

/**
 Returns nil on error.
 */
- (ABFileStream *)fileStreamWithFile:(NSURL *)file streamID:(NSString *)streamID chunkSize:(NSInteger)chunkSize response:(ABStreamFileResponse **)response messageID:(NSString *)messageID streamHandler:(void(^)(NSString *streamID, NSData *data, BOOL reachedEOF))streamHandler;

@end
