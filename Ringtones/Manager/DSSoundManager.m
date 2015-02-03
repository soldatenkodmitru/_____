//
//  DSSoundManager.m
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSoundManager.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@implementation DSSoundManager

+ (DSSoundManager *)sharedManager {
    
    static DSSoundManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DSSoundManager alloc]init];
    });
    
    return manager;
}

- (void) play{
    
    [self resetStreamer];
    [self.streamer play];
    
}
- (void) playSong:(DSSong*) song{
    
}
- (void) stop{
    
    [self.streamer stop];
    
}
- (void) pause{
    
    [self.streamer pause];
    
}
- (void) backward{
    
}
- (void) forward{
    
}



- (void) cancelStreamer
{
    if (self.streamer != nil) {
        [self.streamer pause];
        [self.streamer removeObserver:self forKeyPath:@"status"];
        [self.streamer removeObserver:self forKeyPath:@"duration"];
        [self.streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        self.streamer = nil;
    }
}

- (void) resetStreamer
{
    [self cancelStreamer];
    
    NSData* data;
    
    if ( self.song.saveFileLink != nil)
        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.song.saveFileLink]];
    
    if (self.song.audioFileURL == nil){
        if (data == nil)
            self.song.audioFileURL = [NSURL URLWithString: self.song.fileLink];
        else
            self.song.audioFileURL = [NSURL fileURLWithPath:self.song.saveFileLink];
    }
    
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:self.song];
    
    if ([self.playlist.songsArray count] != self.activeIndex)
     //   [self.streamer setHintWithAudioFile:self.song];
    //    [self.streamer setHintWithAudioFile:[self.playlist.songsArray objectAtIndex:(self.activeIndex+1)]];
    [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    
}
- (void) updateStatus{
    
    if (self.streamer.status ==  DOUAudioStreamerPlaying && self.isPlaying == NO){
        self.isPlaying = YES;
      //  [self.delegate statusChanged:self.isPlaying];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
