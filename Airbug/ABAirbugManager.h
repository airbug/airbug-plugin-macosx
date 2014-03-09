//
//  ABAirbugManager.h
//  Airbug
//
//  Created by Richard Shin on 2/7/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABAirbugCommunicator.h"
#import "ABIncomingDataBuilder.h"
#import "ABOutgoingDataBuilder.h"

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
 The designated initializer for ABAirbugManager.
 @param communicator The object used to communicate with the Airbug servers.
 @param incomingBuilder Transforms incoming data received from Airbug servers into readable objects.
 @param outgoingBuilder Transforms objects into data to be sent to Airbug servers.
 */
- (id)initWithCommunicator:(ABAirbugCommunicator *)communicator
       incomingDataBuilder:(ABIncomingDataBuilder *)incomingBuilder
       outgoingDataBuilder:(ABOutgoingDataBuilder *)outgoingBuilder;

/**
 Upload image to Airbug.
 @param image
        Image data to upload. Must not be nil.
 @param completionHandler
        Block to execute when upload has completed successfully or unsuccessfully. The @c NSURL parameter contains
        the URL of the uploaded image if successful, nil otherwise. The @c NSError parameter contains information
        on any reasons for upload failure.
 */
- (void)uploadPNGImageData:(NSData *)imageData onCompletion:(void (^)(NSURL *, NSError *))completionHandler;

/**
 Upload video to Airbug.
 @param videoData Video data to upload. Must not be nil.
 @param progress Pointer to progress object to get upload progress updates
 @param completionHandler Block to execute when upload has completed successfully or unsuccessfully. The @c NSURL parameter contains
 the URL of the uploaded image if successful, nil otherwise. The @c NSError parameter contains information
 on any reasons for upload failure.
 */
- (void)uploadQuickTimeVideoFile:(NSURL *)fileURL progress:(NSProgress **)progress onCompletion:(void (^)(NSURL *, NSError *))completionHandler;


typedef NS_ENUM(NSInteger, ABAirbugManagerErrorCode) {
    ABAirbugManagerCommunicationError,
    ABAirbugManagerDataError
};

@end
