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
NSString * const AirbugImageUploadURL = @"http://localhost:3000/imageupload";

#pragma mark - Public

- (void)sendPNGImageData:(NSData *)imageData withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSParameterAssert(imageData);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];
    [manager POST:AirbugImageUploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, error);
    }];
}

@end
