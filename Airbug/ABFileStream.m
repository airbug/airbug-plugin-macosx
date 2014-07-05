//
//  ABFileStream.m
//  Airbug
//
//  Created by Richard Shin on 7/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABFileStream.h"

@implementation ABFileStream

- (instancetype)initWithFile:(NSURL *)file streamID:(NSString *)streamID chunkSize:(NSInteger)chunkSize streamHandler:(void(^)(NSString *streamID, NSData *data, BOOL reachedEOF))streamHandler;
{
    NSParameterAssert(streamID);
    NSParameterAssert(file);
    NSParameterAssert(chunkSize > 0);
    NSParameterAssert(streamHandler);
    
    if (self = [super init]) {
        _file = file;
        _streamID = streamID;
        _chunkSize = chunkSize;
        _streamHandler = streamHandler;
    }
    return self;
}
//
- (void)start
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[self.file absoluteString]];

    if (!fileHandle) {
        NSLog(@"Unable to find file");
        return;
    }
    
    dispatch_queue_t readingQueue = dispatch_queue_create("ReadingQueue", 0);
    dispatch_async(readingQueue, ^{
        NSData *chunk = [fileHandle readDataOfLength:self.chunkSize];
        unsigned long long position = 0;
        while (chunk.length > 0) {
            self.streamHandler(self.streamID, chunk, NO);
            position += self.chunkSize;
            [fileHandle seekToFileOffset:position];
            chunk = [fileHandle readDataOfLength:self.chunkSize];
        }
        self.streamHandler(self.streamID, nil, YES);
    });
}

@end
