//
//  ABAirbugCommunicator.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class ABAirbugCommunicator
 @description Handles network communication with Airbug backend servers.
*/

@interface ABAirbugCommunicator : NSObject

extern NSString *const ABAirbugCommunicatorError;

@property (nonatomic) BOOL isLoggedIn;

/**
 Upload image data to the image endpoint.
 @param imageData PNG image data to upload. Cannot be nil.
 @param parameters Parameters to be encoded and sent to the server
 @param completionHandler On success, returns JSON server response as an NSDictionary. NSError is nil if no error.
 */
- (void)sendPNGImageData:(NSData *)imageData withParameters:(NSDictionary *)parameters onCompletion:(void (^)(NSDictionary *jsonDictionary, NSError *error))completionHandler;

/**
 Upload video data to the image endpoint.
 @param fileURL URL to the Quicktime video file to upload. Cannot be nil.
 @param parameters Parameters to be encoded and sent to the server
 @param completionHandler On success, returns JSON server response as an NSDictionary. NSError is nil if no error.
 */
- (void)sendQuickTimeVideoFile:(NSURL *)fileURL withParameters:(NSDictionary *)parameters progress:(NSProgress **)progress onCompletion:(void (^)(NSDictionary *, NSError *))completionHandler;

/**
 Authenticate with the airbug server.
 @param username The username
 @param password The password
 @param completionHandler A block that's executed after the login succeeds or fails.
 */
- (void)logInWithUsername:(NSString *)username password:(NSString *)password onCompletion:(void(^)(NSError *error))completionHandler;

/**
 Log out from this user's session. Deletes the session authentication cookie.
 */
- (void)logOut;

@end
