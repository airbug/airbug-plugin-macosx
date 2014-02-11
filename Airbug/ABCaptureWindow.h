//
//  ABCaptureAreaWindow.h
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABCaptureAreaView.h"

/**
 Displays an overlay on the screen to allow users to capture a specific area. When an area is captured, it sends
 the capture data (screen, rect) in an @c NSDictionary object.
 */
@interface ABCaptureWindow : NSWindow

extern NSString * const ABCaptureWindowDidCaptureNotification;
extern NSString * const ABCaptureWindowScreenKey;
extern NSString * const ABCaptureWindowRectKey;

/**
 The string content for the instructions label
 */
@property (copy, nonatomic) NSAttributedString *instructions;

@end
