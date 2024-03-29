//
//  ABFileSystemManager.m
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABFileSystemManager.h"
#import "ABDirectoryContents.h"
#import "ABDirectoryItem.h"
#import "ABStreamFileResponse.h"
#import "ABFileStream.h"

@interface ABFileSystemManager ()
@property (strong, nonatomic) NSArray *availableDirectories;
@end

@implementation ABFileSystemManager

NSString *const ABFavoriteDirectoriesKey = @"ABFavoriteDirectoriesKey";

- (instancetype)init
{
    if (self = [super init]) {
        self.availableDirectories = [[NSUserDefaults standardUserDefaults] arrayForKey:ABFavoriteDirectoriesKey];
    }
    return self;
}

// TODO: set up ability to set available user directories
- (void)setAvailableDirectories:(NSArray *)availableDirectories
{
    _availableDirectories = availableDirectories;
    if (!self.availableDirectories) {
        // TODO: how do you get the current user's home dir?
        self.availableDirectories = @[@"/Users/skunkworks"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_availableDirectories forKey:ABFavoriteDirectoriesKey];
}

- (ABDirectoryContents *)contentsOfDirectory:(NSString *)directory showHiddenFiles:(BOOL)showHiddenFiles
{
    ABDirectoryContents *directoryContents = [[ABDirectoryContents alloc] init];
    directoryContents.rootDirectory = directory;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        directoryContents.status = ABDirectoryContentsStatusDirectoryNotFound;
        directoryContents.responseStatus = ABResponseStatusError;
        return directoryContents;
    }
    if (!isDirectory) {
        directoryContents.status = ABDirectoryContentsStatusNotADirectory;
        directoryContents.responseStatus = ABResponseStatusError;
        return directoryContents;
    }
    
    NSURL *directoryURL = [NSURL URLWithString:directory];
    NSDirectoryEnumerationOptions options = showHiddenFiles ? 0 : NSDirectoryEnumerationSkipsHiddenFiles;
    NSError *error;
    NSArray *fileURLs = [fileManager contentsOfDirectoryAtURL:directoryURL
                                   includingPropertiesForKeys:@[NSURLFileResourceTypeKey]
                                                      options:options
                                                        error:&error];
    if (error) {
        // TODO: figure out a way to tell if access was denied, then set the status to
        // ABDirectoryContentsStatusAccessDenied
        NSLog(@"Error occurred while reading contents of %@: %@", directory, [error localizedDescription]);
        directoryContents.status = ABDirectoryContentsStatusUnknown;
        directoryContents.responseStatus = ABResponseStatusError;
        return directoryContents;
    }
    
    directoryContents.status = ABDirectoryContentsStatusSuccess;
    directoryContents.responseStatus = ABResponseStatusSuccess;
    
    NSMutableArray *mutableDirectoryItems = [NSMutableArray array];
    for (NSURL *fileURL in fileURLs) {
        ABDirectoryItem *item = [[ABDirectoryItem alloc] init];
        item.name = [fileURL lastPathComponent];

        NSString *type;
        [fileURL getResourceValue:&type forKey:NSURLFileResourceTypeKey error:NULL];
        if ([type isEqualToString:NSURLFileResourceTypeRegular]) {
            item.itemType = ABDirectoryItemTypeFile;
        } else if ([type isEqualToString:NSURLFileResourceTypeDirectory]) {
            item.itemType = ABDirectoryItemTypeDirectory;
        } else if ([type isEqualToString:NSURLFileResourceTypeSymbolicLink]) {
            item.itemType = ABDirectoryItemTypeSymbolicLink;
        } else {
            item.itemType = ABDirectoryItemTypeUnknown;
        }
        
        [mutableDirectoryItems addObject:item];
    }

    directoryContents.contents = [mutableDirectoryItems copy];
    return directoryContents;
}

- (void)addDirectoryToAvailableDirectories:(NSString *)directory
{
    NSParameterAssert(directory);
    self.availableDirectories = [self.availableDirectories arrayByAddingObject:directory];
}

- (ABFileStream *)fileStreamWithFile:(NSURL *)file
                            streamID:(NSString *)streamID
                           chunkSize:(NSInteger)chunkSize
                            response:(ABStreamFileResponse **)response
                           messageID:(NSString *)messageID
                       streamHandler:(void(^)(NSString *streamID, NSData *data, BOOL reachedEOF))streamHandler
{
    ABStreamFileResponse *streamFileResponse = [[ABStreamFileResponse alloc] init];
    streamFileResponse.responseID = messageID;
    *response = streamFileResponse;
    
    // Validate that file exists and is file
    BOOL isDirectory;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[file absoluteString] isDirectory:&isDirectory];
    
    if (!fileExists) {
        streamFileResponse.responseStatus = ABResponseStatusError;
        streamFileResponse.streamFileStatus = ABStreamFileStatusNotFound;
        return nil;
    }
    if (isDirectory) {
        streamFileResponse.responseStatus = ABResponseStatusError;
        streamFileResponse.streamFileStatus = ABStreamFileStatusNotAFile;
        return nil;
    }
    
    BOOL isFileReadable = [[NSFileManager defaultManager] isReadableFileAtPath:[file absoluteString]];
    if (!isFileReadable) {
        streamFileResponse.responseStatus = ABResponseStatusError;
        streamFileResponse.streamFileStatus = ABStreamFileStatusAccessDenied;
        return nil;
    }
    
    streamFileResponse.responseStatus = ABResponseStatusSuccess;
    streamFileResponse.streamFileStatus = ABStreamFileStatusSuccess;
    ABFileStream *fileStream = [[ABFileStream alloc] initWithFile:file streamID:streamID chunkSize:chunkSize streamHandler:streamHandler];

    return fileStream;
}

@end
