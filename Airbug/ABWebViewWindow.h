//
//  ABWebViewWindow.h
//  Airbug
//
//  Created by Richard Shin on 5/15/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface ABWebViewWindow : NSWindow

@property (weak) IBOutlet WebView *webView;

@end
