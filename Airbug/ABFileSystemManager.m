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

@interface ABFileSystemManager ()
@property (strong, nonatomic) NSArray *availableDirectories;
@end

@implementation ABFileSystemManager

- (instancetype)init
{
    if (self = [super init]) {
        // TODO: read available directories from user preferences.
    }
    return self;
}

- (NSArray *)availableDirectories
{
    // TODO: a real implementation
    return @[@"/Users/skunkworks"];
}

// TODO: set up ability to set available user directories
- (void)setAvailableDirectories:(NSArray *)availableDirectories
{
    self.availableDirectories = availableDirectories;
    // TODO: write available directories to user preferences.
}

- (ABDirectoryContents *)contentsOfDirectory:(NSString *)directory showHiddenFiles:(BOOL)showHiddenFiles
{
    ABDirectoryContents *directoryContents = [[ABDirectoryContents alloc] init];
    directoryContents.rootDirectory = directory;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        directoryContents.status = ABDirectoryContentsStatusDirectoryNotFound;
        return directoryContents;
    }
    if (!isDirectory) {
        directoryContents.status = ABDirectoryContentsStatusNotADirectory;
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
        return directoryContents;
    }
    
    directoryContents.status = ABDirectoryContentsStatusSuccess;
    
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

@end
