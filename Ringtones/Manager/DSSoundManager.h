//
//  DSSoundManager.h
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioStreamer.h"
#import "DSSong.h"
#import "DSPlaylistPlayer.h"



@protocol DSSoundManagerDelegate
- (void) activeSongDidChange:(DSSong*)song;
- (void) statusChanged:(BOOL) playStatus;

@end

@interface DSSoundManager : NSObject


@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (strong, nonatomic) DSSong* song;
@property (strong, nonatomic) DSSong* nextSong;
@property (strong, nonatomic) DSPlaylistPlayer *playlist;
@property (assign, nonatomic) int activeIndex;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL wasPlaying;

@property (assign) id <DSSoundManagerDelegate> delegate;

+ (DSSoundManager *)sharedManager;

- (void) play;
- (void) playSong:(DSSong*) song;
- (void) stop;
- (void) pause;
- (void) backward;
- (void) forward;
- (void) resetStreamer;

@end
