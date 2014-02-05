//
//  ABScreenCapturerTests.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ABScreenCapturer.h"

@interface ABScreenCapturerTests : XCTestCase
{
    ABScreenCapturer *capturer;
}
@end

@implementation ABScreenCapturerTests

#pragma mark - Utility methods

- (ABScreenCapturer *)newScreenCapturer {
    return [[ABScreenCapturer alloc] init];
}

#pragma mark - Tests

- (void)testCaptureMainDisplayWhenCalledReturnsNSImage
{
    capturer = [self newScreenCapturer];
    
    NSImage *captureImage = [capturer captureMainDisplay];
    
    XCTAssertNotNil(captureImage);
}

@end
