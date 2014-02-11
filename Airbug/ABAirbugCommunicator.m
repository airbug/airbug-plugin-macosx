//
//  ABAirbugCommunicator.m
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABAirbugCommunicator.h"
#import "AFNetworking.h"

@implementation ABAirbugCommunicator

NSString *const ABAirbugCommunicatorError = @"ABAirbugCommunicatorError";
NSString * const AirbugImageUploadURL = @"";

#pragma mark - Public

- (void)sendPNGImageData:(NSData *)imageData onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSParameterAssert(imageData);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{};
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];
    [manager POST:AirbugImageUploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error with status code %ld: %@", operation.response.statusCode, error);
        completionHandler(nil, error);
    }];
}

@end
