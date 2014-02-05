//
//  ABScreenCapturerTests.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ABScreenCapture.h"

@interface ABScreenCapturerTests : XCTestCase
{
    ABScreenCapture *capturer;
}
@end

@implementation ABScreenCapturerTests

#pragma mark - Utility methods

- (ABScreenCapture *)newScreenCapturer {
    return [[ABScreenCapture alloc] init];
}

#pragma mark - Tests

- (void)testCaptureMainDisplayWhenCalledReturnsNSImage
{
    capturer = [self newScreenCapturer];
    
    NSImage *captureImage = [capturer captureMainDisplay];
    
    XCTAssertNotNil(captureImage);
}

@end
