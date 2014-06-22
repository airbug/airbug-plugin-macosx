//
//  ABOutgoingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABOutgoingDataBuilder.h"

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
    NSParameterAssert(availableDirectories);
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
@end