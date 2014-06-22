//
//  ABDirectoryItem.h
//  Airbug
//
//  Created by Richard Shin on 6/21/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ABDirectoryItemType) {
    ABDirectoryItemTypeUnknown = 0,
    ABDirectoryItemTypeDirectory,
    ABDirectoryItemTypeFile,
    ABDirectoryItemTypeSymbolicLink
};

@interface ABDirectoryItem : NSObject

@property (strong, nonatomic) NSString *name;

@property (nonatomic) ABDirectoryItemType itemType;

@end
