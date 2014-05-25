//
//  ABNetworkCommunicator.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/**
 @class ABNetworkCommunicator
 @description Handles network communication with Airbug backend servers.
*/

@interface ABNetworkCommunicator : NSObject

extern NSString * const ABNetworkCommunicatorError;
extern NSString * const AirbugAPIBridgeURL;

/**
 The web view through which all communication occurs with airbug server
 */
@property (strong, nonatomic) WebView *webView;

/**
 Called when the communicator receives JSON communication from the JS plugin layer.
 */
@property (copy, nonatomic) void (^receivedJSONObjectHandler)(id JSONObject);

/**
 Initialiize with a web view instance. Communicator will use this web view to load airbug.
 */
- (id)initWithWebView:(WebView *)webView;

/**
 Sends JSON request to client JS plugin layer.
 */
- (BOOL)sendJSONRequest:(id)JSONObject error:(NSError *)error;

/**
 Receive JSON messages from client JS plugin layer.
 */
- (void)receivedJSONString:(NSString *)JSONString;

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

@end
