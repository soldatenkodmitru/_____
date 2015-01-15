//
//  DSPlayerViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSPlayerViewController.h"



static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@implementation DSPlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

    self.userRate.rating = [[DSDataManager dataManager]existsLikeForSong:self.song.id_sound];
    if (self.userRate.rating > 0)
        self.userRate.editable = NO;
    else
        self.userRate.editable = YES;
    self.userRate.delegate = self;
    self.userRate.notSelectedImage = [UIImage imageNamed:@"ic_star_gray_empty.png"];
    self.userRate.fullSelectedImage = [UIImage imageNamed:@"ic_star_gray_filled.png"];
     self.userRate.maxRating = 5;
    
    self.serverRate.rating = self.song.rating;
    self.serverRate.notSelectedImage = [UIImage imageNamed:@"ic_star_white.png"];
    self.serverRate.halfSelectedImage = [UIImage imageNamed:@"ic_star_white_yellow_half.png"];
    self.serverRate.fullSelectedImage = [UIImage imageNamed:@"ic_star_white_yellow.png"];
    self.serverRate.maxRating = 5;
    
    self.titleLbl.text = self.song.title;
    self.artistLbl.text = self.song.artist;
    self.imageSong.image = self.pictureSong;
    self.startLbl.text = @"00:00";
    self.endLbl.text = @"00:00";
   
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetStreamer];
    [self.streamer pause];
    
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayTime) userInfo:nil repeats:YES];
    self.volumeProgress.progress = [DOUAudioStreamer volume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [self.streamer stop];
    [self cancelStreamer];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Self Methods

- (NSString*) changeTimetoFloat: (float) length
{
    int minutes = (int) floor(length / 60);
    int seconds = (int) length - (minutes * 60);
    
    NSString* strMinutes = [NSString stringWithFormat: @"%d", minutes];
    if (minutes < 10) {
        strMinutes = [NSString stringWithFormat: @"0%@", strMinutes];
    }
    
    NSString* strSeconds = [NSString stringWithFormat: @"%d", seconds];
    if (seconds < 10) {
        strSeconds = [NSString stringWithFormat: @"0%@", strSeconds];
    }
    
    NSString *strTime = [NSString stringWithFormat: @"%@:%@", strMinutes, strSeconds];
    
    return strTime;
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
    
        self.song.audioFileURL = [NSURL URLWithString: self.song.fileLink];
       // self.song.audioFileURL = [NSURL fileURLWithPath:self.song.fileLink];
        self.streamer = [DOUAudioStreamer streamerWithAudioFile:self.song];
        [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Timer
- (void) updatePlayTime
{
    
    //    NSLog(@"current time = %f", audioPlayer.currentTime);
    NSString* strPlayedTime = [self changeTimetoFloat: self.audioPlayer.progress];
    
    float fRemainTime = self.audioPlayer.duration -self.audioPlayer.progress;
    NSString* strRemainTime = [NSString stringWithFormat: @"%@", [self changeTimetoFloat: fRemainTime]];
    
    [self.sldPlay setValue: self.audioPlayer.progress animated:YES];
    [self.lblStartTime setText: strPlayedTime];
     self.endLbl.text = [NSString stringWithFormat: @"%@", self.audioPlayer.duration];
}

#pragma mark - DSRateViewDelegate
- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    NSLog(@"%f",rating);
    [[DSServerManager sharedManager] setSongRating:[NSString stringWithFormat:@"%.0f",rating] forSong:[NSString stringWithFormat:@"%ld", (long)self.song.id_sound ] OnSuccess:^(NSObject *result) {
        NSLog(@"Set Rating");
        [[DSDataManager dataManager] addLikeForSong:self.song.id_sound withRating:rating];
        self.userRate.editable = NO;
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
}
@end
