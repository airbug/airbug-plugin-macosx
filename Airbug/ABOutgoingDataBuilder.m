//
//  ABOutgoingDataBuilder.m
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABOutgoingDataBuilder.h"

@implementation ABOutgoingDataBuilder

- (NSDictionary *)createLoginRequestForUsername:(NSString *)username password:(NSString *)password
{
    NSParameterAssert(username);
    NSParameterAssert(password);
    return @{
             @"type" : @"LoginRequest",
             @"data" : @{
                         @"username" : username,
                         @"password" : password
                         }
             };
}

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

@end