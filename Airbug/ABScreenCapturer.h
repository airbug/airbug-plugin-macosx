//
//  ABScreenCapturer.h
//  Airbug
//
//  Created by Richard Shin on 2/4/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABScreenCapturer : NSObject <NSAnimationDelegate>

- (NSImage *)captureMainDisplay;
- (void)displayOverlayOnMainDisplay;

@end
