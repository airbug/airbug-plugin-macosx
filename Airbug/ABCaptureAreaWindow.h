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
@interface ABCaptureAreaWindow : NSWindow <ABCaptureAreaViewDelegate>

extern NSString * const ABCaptureAreaWindowDidCaptureAreaNotification;
extern NSString * const ABCaptureAreaWindowScreenKey;
extern NSString * const ABCaptureAreaWindowRectKey;

@end
