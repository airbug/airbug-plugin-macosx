//
//  ABDirectoryContentsResponse.h
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ABDirectoryContentsStatus) {
    ABDirectoryContentsStatusUnknown = 0,
    ABDirectoryContentsStatusSuccess = 1,
    ABDirectoryContentsStatusAccessDenied,
    ABDirectoryContentsStatusNotADirectory,
    ABDirectoryContentsStatusDirectoryNotFound
};

@interface ABDirectoryContents : NSObject

@property (nonatomic) ABDirectoryContentsStatus status;

@property (strong, nonatomic) NSString *rootDirectory;

/**
 Array of @c ABDirectoryItem objects
 */
@property (strong, nonatomic) NSArray *contents;

@end
