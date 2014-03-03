//
//  ABOutgoingDataBuilder.h
//  Airbug
//
//  Created by Richard Shin on 2/8/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABOutgoingDataBuilder : NSObject

/**
 Returns a dictionary of parameters to send during image upload.
 @param imageData The image data
 */
- (NSDictionary *)parametersForPNGImage:(NSData *)imageData;

/**
 Returns a dictionary of parameters to send during image upload.
 @param imageData The image data
 */
- (NSDictionary *)parametersForQuickTimeVideo:(NSData *)videoData;

@end
