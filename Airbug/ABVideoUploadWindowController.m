//
//  ABVideoUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 3/2/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABVideoUploadWindowController.h"
#import <AVKit/AVKit.h>

@interface ABVideoUploadWindowController ()
@property (weak) IBOutlet AVPlayerView *playerView;
@end

@implementation ABVideoUploadWindowController

#pragma mark - Lifecycle

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.playerView.player = self.player;
}

#pragma mark - Custom accessors

- (void)setPlayer:(AVPlayer *)player {
    _player = player;
    self.playerView.player = player;
}

#pragma mark - Public

- (void)startUpload
{
//    NSData *imageData = [self.image PNGRepresentation];
//    [self.manager uploadPNGImageData:imageData onCompletion:^(NSURL *imageURL, NSError *error) {
//        if (error) {
//            NSLog(@"Error during upload: %@", error);
//            [self updateUIForUploadFailureWithError:error];
//        } else {
//            [self updateUIForUploadSuccess:[imageURL absoluteString]];
//            [self launchBrowserToURL:imageURL];
//        }
//    }];
}

- (NSString *)windowNibName {
    return @"ABVideoUploadWindow";
}

@end
