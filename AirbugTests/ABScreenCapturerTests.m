//
//  ABScreenCapturerTests.m
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ABScreenCapturer.h"

@interface ABScreenCapturer ()
- (NSImage *)imageFromDisplayID:(CGDirectDisplayID)displayID;
@end

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

- (void)testCaptureMainScreenWhenCalledReturnsImage
{
    capturer = [self newScreenCapturer];
    id stubCapturer = [OCMockObject partialMockForObject:capturer];
    NSImage *image = [[NSImage alloc] init];
    [[[[stubCapturer stub] ignoringNonObjectArgs] andReturn:image] imageFromDisplayID:0];
    
    NSImage *captureImage = [capturer captureMainScreen];
    
    XCTAssertEqualObjects(captureImage, image);
}

- (void)testCaptureScreenWithNilScreenReturnsNil
{
    capturer = [self newScreenCapturer];
    
    NSImage *captureImage = [capturer captureScreen:nil];
    
    XCTAssertNil(captureImage);
}

- (void)testCaptureScreenWithAnInvalidScreenReturnsNil
{
    capturer = [self newScreenCapturer];
    NSScreen *invalidScreen = [[NSScreen alloc] init];
    
    NSImage *captureImage = [capturer captureScreen:invalidScreen];
    
    XCTAssertNil(captureImage);
}

- (void)testCaptureScreenWhenCalledReturnsTheCorrectImage
{
    capturer = [self newScreenCapturer];
    id stubCapturer = [OCMockObject partialMockForObject:capturer];
    NSScreen *screen = [NSScreen mainScreen];
    CGDirectDisplayID screenID = [screen.deviceDescription[@"NSScreenNumber"] intValue];
    NSImage *image = [[NSImage alloc] init];
    [[[[stubCapturer stub] ignoringNonObjectArgs] andReturn:image] imageFromDisplayID:screenID];
    
    NSImage *captureImage = [capturer captureScreen:screen];
    
    XCTAssertEqualObjects(captureImage, image);
}

@end
