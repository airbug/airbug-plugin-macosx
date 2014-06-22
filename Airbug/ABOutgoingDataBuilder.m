//
//  ABOutgoingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABOutgoingDataBuilder.h"
#import "ABDirectoryItem.h"
#import "ABDirectoryContents.h"

@implementation ABOutgoingDataBuilder

- (NSDictionary *)createPreviewScreenshotRequestWithImage:(NSImage *)image type:(ABScreenshotType)type
{
    NSParameterAssert(image);
    
    NSData *data = [image TIFFRepresentation];
    NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc] initWithData:data];
    data = [imgRep representationUsingType:NSPNGFileType
                                properties:@{ NSImageCompressionFactor : @(1.0) }];
    NSString *base64EncodedImage = [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    if (!base64EncodedImage) base64EncodedImage = @"";
    
    return @{
             @"type" : @"PreviewScreenshot",
             @"data" : @{
                         @"screenshotType" : [ABScreenshotRequest stringFromType:type],
                         @"imageData" : base64EncodedImage
                        }
             };
}

- (NSDictionary *)createRestoreCookieResponseForMessageID:(NSString *)messageID
{
    NSParameterAssert(messageID);
    return @{ @"ackId" : messageID };
}

- (NSDictionary *)createShowLoginPageRequest {
    return @{ @"type": @"ShowLoginPage" };
}

- (NSDictionary *)createLogoutRequest {
    return @{ @"type" : @"Logout" };
}

- (NSDictionary *)createTryConnectRequest {
    return @{ @"type" : @"TryConnect" };
}

- (NSDictionary *)createAvailableDirectoriesResponse:(NSArray *)availableDirectories {
    NSParameterAssert([availableDirectories isKindOfClass:[NSArray class]]);
    for (id obj in availableDirectories) {
        NSAssert([obj isKindOfClass:[NSString class]], @"Must contain string objects only");
    }
    
    return @{
             @"type" : @"AvailableDirectories",
             @"data" : @{
                            @"directories": availableDirectories
                        }
             };
}

- (NSDictionary *)createDirectoryContentsResponse:(ABDirectoryContents *)response
{
    NSParameterAssert([response isKindOfClass:[ABDirectoryContents class]]);

    NSString *successString;
    switch (response.status) {
        case ABDirectoryContentsStatusSuccess:
            successString = @"success"; break;
        case ABDirectoryContentsStatusAccessDenied:
            successString = @"accessDenied"; break;
        case ABDirectoryContentsStatusDirectoryNotFound:
            successString = @"notFound"; break;
        case ABDirectoryContentsStatusNotADirectory:
            successString = @"notADirectory"; break;
        default:
            successString = @"unknown"; break;
    }
    
    NSMutableArray *itemsArray = [NSMutableArray array];
    for (ABDirectoryItem *item in response.contents) {

        NSString *itemTypeString;
        switch (item.itemType) {
            case ABDirectoryItemTypeDirectory:
                itemTypeString = @"dir"; break;
            case ABDirectoryItemTypeFile:
                itemTypeString = @"file"; break;
            case ABDirectoryItemTypeSymbolicLink:
                itemTypeString = @"symlink"; break;
            default:
                itemTypeString = @"unknown"; break;
        }
        
        [itemsArray addObject:@{
                                @"name" : item.name,
                                @"metadata" : @{
                                        @"type" : itemTypeString
                                        }
                                }];
    }
    
    return @{
             @"type" : @"DirectoryContents",
             @"data" : @{
                         @"status": successString,
                         @"rootDirectory" : response.rootDirectory,
                         @"items" : [itemsArray copy]
                     }
             };
}

@end