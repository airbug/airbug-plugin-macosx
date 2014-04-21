//
//  ABVideoUploadWindowController.m
//  Airbug
//
//  Created by Richard Shin on 3/2/14.
//  Copyright (c) 2014 Airbug. All rights reserved.
//

#import "ABVideoUploadWindowController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ABVideoUploadWindowController ()
@property (weak) IBOutlet AVPlayerView *playerView;
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation ABVideoUploadWindowController

#pragma mark - Lifecycle

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.fileURL];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerView.player = self.player;
}

#pragma mark - Public

- (void)startUpload {
    [self.manager uploadQuickTimeVideoFile:self.fileURL progress:nil onCompletion:self.completionHandler];
}

- (NSString *)windowNibName {
    return @"ABVideoUploadWindow";
}

@end
