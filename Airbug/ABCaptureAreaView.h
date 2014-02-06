//
//  ABCaptureAreaView.h
//  Airbug
//
//  Created by Richard Shin on 2/6/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ABCaptureAreaViewDelegate <NSObject>
- (void)didCaptureArea:(CGRect)rect;
@end

@interface ABCaptureAreaView : NSView

@end
