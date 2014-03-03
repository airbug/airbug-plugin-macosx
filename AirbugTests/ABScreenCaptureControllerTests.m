//
//  ABScreenCaptureControllerTests.m
//  Airbug
//
//  Created by Richard Shin on 2/5/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ABCaptureManager.h"
#import "FakeABScreenCaptureControllerDelegate.h"

@interface ABScreenCaptureControllerTests : XCTestCase
{
    ABCaptureManager *controller;
}
@end

@implementation ABScreenCaptureControllerTests

#pragma mark - Utility

- (ABCaptureManager *)newScreenCaptureController {
    return [[ABCaptureManager alloc] init];
}

#pragma mark - Tests

- (void)testItHasADelegate
{
    controller = [self newScreenCaptureController];
    id fakeDelegate = [[FakeABScreenCaptureControllerDelegate alloc] init];

    controller.delegate = fakeDelegate;
    
    XCTAssertNotNil(controller.delegate);
}

- (void)testDelegateWhenAssignedToNonConformingObjectThrowsException
{
    controller = [self newScreenCaptureController];
    id <ABCaptureManagerDelegate> nonConformingObj = (id <ABCaptureManagerDelegate>)[NSNull null];

    XCTAssertThrows(controller.delegate = nonConformingObj);
}

- (void)testTakeScreenshotWhenUserTakesScreenshotCallsDelegateDidTakeScreenshot
{
    controller = [self newScreenCaptureController];
    NSImage *image = [[NSImage alloc] init];
    id stubCapturer = [OCMockObject mockForClass:[ABScreenCapturer class]];
    [[[stubCapturer stub] andReturn:image] captureMainScreen];
    controller.capturer = stubCapturer;
    id mockDelegate = [OCMockObject partialMockForObject:[[FakeABScreenCaptureControllerDelegate alloc] init]];
    [[mockDelegate expect] didTakeScreenshot:image];
    controller.delegate = mockDelegate;
    
    [controller captureScreenshot];
    
    [mockDelegate verify];
}

// TODO: May want to augment functionality to allow the user to mouse over to different screens, which highlights
// the screen with a translucent gray window. Window has instructions to click mouse to capture, Esc to cancel.
// Could probably do this with an event loop?

// TODO: Do we want to return the results of screenshotting via delegation? Seems like a good idea



@end
