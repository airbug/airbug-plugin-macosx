//
//  ABCaptureAreaWindow.h
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ABCaptureAreaView.h"

@interface ABCaptureAreaWindow : NSWindow <ABCaptureAreaViewDelegate>

extern NSString * const ABCaptureAreaWindowDidCaptureAreaNotification;

@end
