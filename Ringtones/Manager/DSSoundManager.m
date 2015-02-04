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
    
    
    if (self.streamer.status!= DOUAudioStreamerPaused )
    [self resetStreamer];
    [self.streamer play];
    self.wasPlaying = YES;
    
}
- (void) playSong:(DSSong*) song{
    [self resetStreamer:song];
    [self.streamer play];
    self.wasPlaying = YES;
}
- (void) stop{
    
    [self.streamer stop];
    self.wasPlaying = NO;
}
- (void) pause{
    
    [self.streamer pause];
    self.wasPlaying = NO;
}
- (void) backward{
    
    if (self.activeIndex -1  >= 0 ) {
        self.activeIndex = self.activeIndex - 1;
        self.song = [self.playlist.songsArray objectAtIndex:(self.activeIndex)];
        [self.delegate activeSongDidChange:self.song];
        [self resetStreamer];
        if(self.wasPlaying)
            [self play];
    }
   
}
- (void) forward{
    if (self.activeIndex +1 < [self.playlist.songsArray count]) {
        self.activeIndex = self.activeIndex + 1;
        self.song = [self.playlist.songsArray objectAtIndex:(self.activeIndex)];
        [self.delegate activeSongDidChange:self.song];
        [self resetStreamer];
        if (self.wasPlaying)
            [self play];
    }
   
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

- (void) setAudioLink:(DSSong*) song{
    
    
    NSData* data;
    
    if ( song.saveFileLink != nil)
        data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:song.saveFileLink]];
    

    if ( song.audioFileURL == nil){
        if (data == nil)
            song.audioFileURL = [NSURL URLWithString: song.fileLink];
        else
            song.audioFileURL = [NSURL fileURLWithPath: song.saveFileLink];
    }
}


- (void) resetStreamer:(DSSong*) song
{
    [self cancelStreamer];
    
    switch (song.versionAudio){
        case sFull:
             song.audioFileURL = [NSURL URLWithString: song.fileLink];
            break;
        case sCut:
             song.audioFileURL = [NSURL URLWithString: song.cutLink];
            break;
        case sRignton:
             song.audioFileURL = [NSURL URLWithString: song.ringtonLink];
            break;
    }
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:song];
    
    if ([self.playlist.songsArray count] != self.activeIndex){
        self.nextSong = [self.playlist.songsArray objectAtIndex:(self.activeIndex+1)];
        [self setAudioLink:self.nextSong];
        [DOUAudioStreamer setHintWithAudioFile:self.nextSong];
    }
    [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    
}


- (void) resetStreamer
{
    [self cancelStreamer];
    
    [self setAudioLink:self.song];
    
    self.streamer = [DOUAudioStreamer streamerWithAudioFile:self.song];
    
    if ([self.playlist.songsArray count] != self.activeIndex+1){
        self.nextSong = [self.playlist.songsArray objectAtIndex:(self.activeIndex+1)];
        [self setAudioLink:self.nextSong];
        [DOUAudioStreamer setHintWithAudioFile:self.nextSong];
    }
    [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    
}
- (void) updateStatus{
    
    if (self.streamer.status ==  DOUAudioStreamerPlaying && self.isPlaying == NO){
        self.isPlaying = YES;
    }
    
    if (self.streamer.status == DOUAudioStreamerFinished || self.streamer.status ==  DOUAudioStreamerPaused || self.streamer.status == DOUAudioStreamerError)  {
        
        self.isPlaying = NO;
       
    }
    if (self.streamer.status == DOUAudioStreamerFinished){
         [self forward];
    }
     [self.delegate statusChanged:self.isPlaying];
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
