//
//  ABFileStream.h
//  Airbug
//
//  Created by Richard Shin on 7/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABFileStream : NSObject

- (instancetype)initWithFile:(NSURL *)file streamID:(NSString *)streamID chunkSize:(NSInteger)chunkSize streamHandler:(void(^)(NSString *streamID, NSData *data, BOOL reachedEOF))streamHandler;

/**
 Reads file and begins executing stream handler
 */
- (void)start;

@property (strong, nonatomic) NSURL *file;
@property (strong, nonatomic) NSString *streamID;
@property (nonatomic) NSInteger chunkSize;
@property (copy, nonatomic) void(^streamHandler)(NSString *streamID, NSData *data, BOOL reachedEOF);

@end
