//
//  ABAirbugManager.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABNetworkCommunicator.h"
#import "ABIncomingDataBuilder.h"
#import "ABOutgoingDataBuilder.h"
#import "ABScreenshotRequest.h"

@protocol ABAirbugManagerDelegate <NSObject>
- (void)didReceiveNotification:(NSUserNotification *)notification;
- (void)didReceiveWindowVisibilityRequest:(BOOL)showWindow;
- (void)didReceiveWindowResizeRequest:(NSSize)size;
- (void)didReceiveScreenshotRequest:(ABScreenshotType)screenshotType;
- (void)didReceiveOpenBrowserRequest:(NSURL *)url;
- (void)didLogInSuccessfully;
- (void)loginFailedWithError:(NSError *)error;
- (void)failedToSendJSONObject:(id)JSONObject error:(NSError *)error;
@end

typedef NS_ENUM(NSInteger, ABAirbugManagerErrorCode) {
    ABAirbugManagerCommunicationError,
    ABAirbugManagerDataError
};

/**
 @class ABAirbugManager
 @description Manages network interactions with Airbug backend servers.
 @discussion @c ABAirbugManager is designed as a facade class that delegates most of its responsibilities to other
 objects which it is composed of. Clients ask it to perform operations, but behind the scenes it only manages the
 workflow of the data between those objects. The behavior of @c ABAirbugManager can be altered by changing these
 objects via its public properties.
 */

@interface ABAirbugManager : NSObject

/**
 Delegate of ABAirbugManager that receives messages when various network events occur
 */
@property (weak, nonatomic) id <ABAirbugManagerDelegate> delegate;
/**
 Returns @c YES if currently authenticated
 */
@property (readonly) BOOL isLoggedIn;

/**
 The designated initializer for ABAirbugManager.
 @param communicator The object used to communicate with the Airbug servers.
 @param incomingBuilder Transforms incoming data received from Airbug servers into readable objects.
 @param outgoingBuilder Transforms objects into data to be sent to Airbug servers.
 */
- (id)initWithCommunicator:(ABNetworkCommunicator *)communicator
       incomingDataBuilder:(ABIncomingDataBuilder *)incomingBuilder
       outgoingDataBuilder:(ABOutgoingDataBuilder *)outgoingBuilder;

/**
 Authenticate with the airbug server. Response to login is sent via delegate.
 @param username The username
 @param password The password
 */
- (void)logInWithUsername:(NSString *)username password:(NSString *)password;

/**
 Log out of the current session.
 */
- (void)logOut;

/**
 Sends request to client plugin JS to preview screenshot.
 @param image Screenshot image
 @param type Type of screenshot
 */
- (void)sendPreviewScreenshotRequestForImage:(NSImage *)image ofType:(ABScreenshotType)type;

/**
 Sends request to client plugin JS to show login page.
 */
- (void)sendShowLoginPageRequest;

@end
