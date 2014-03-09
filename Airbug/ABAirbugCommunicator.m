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
// TODO: Remove stub URLs
NSString * const AirbugImageUploadURL = @"http://localhost:3000/imageupload";
NSString * const AirbugVideoUploadURL = @"http://localhost:3000/videoupload";

#pragma mark - Public

- (void)sendPNGImageData:(NSData *)imageData withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self sendFileData:imageData mimeType:@"image/png" toURL:AirbugImageUploadURL withParameters:parameters onCompletion:^(NSDictionary *jsonDictionary, NSError *error) {
        completionHandler(jsonDictionary, error);
    }];
}

- (void)sendQuickTimeVideoFile:(NSURL *)fileURL withParameters:(NSDictionary *)parameters progress:(NSProgress **)progress onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    [self sendFile:fileURL mimeType:@"video/quicktime" toURL:AirbugVideoUploadURL withParameters:parameters progress:progress onCompletion:^(NSDictionary *jsonDictionary, NSError *error) {
        completionHandler(jsonDictionary, error);
    }];
}

#pragma mark - Private

- (void)sendFileData:(NSData *)fileData mimeType:(NSString *)mimeType toURL:(NSString *)urlString withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *jsonDictionary, NSError *error))completionHandler
{
    NSParameterAssert(fileData);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, error);
    }];
}

- (void)sendFile:(NSURL *)fileURL mimeType:(NSString *)mimeType toURL:(NSString *)urlString withParameters:(NSDictionary *)parameters progress:(NSProgress **)progress onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSString *fileName = [[NSDate date] descriptionWithCalendarFormat:NSCalendarIdentifierISO8601 timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"] locale:nil];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:[fileURL path]] name:@"file" fileName:fileName mimeType:mimeType error:nil];
    } error:nil];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        } else {
            completionHandler(responseObject, nil);
        }
    }];
    
    [uploadTask resume];
}

@end
