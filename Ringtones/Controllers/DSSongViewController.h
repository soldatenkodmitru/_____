//
//  DSSongViewController.h
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//
#import "STKAudioPlayer.h"
#import "ViewController.h"
#import "DSSong.h"
#import "DSRateView.h"
#import "DOUAudioStreamer.h"
#import <AVFoundation/AVFoundation.h>

@interface DSSongViewController : ViewController <STKAudioPlayerDelegate, DSRateViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) IBOutlet UIProgressView *progDownload;
@property (strong, nonatomic) IBOutlet UIButton* downloadBtn;
@property (strong, nonatomic) IBOutlet UISlider* sldPlay;
@property (strong, nonatomic) IBOutlet UILabel* lblStartTime;
@property (strong, nonatomic) IBOutlet UILabel* lblEndTime;
@property (strong, nonatomic) IBOutlet DSRateView* rateView;

- (IBAction)playAction:(id)sender;
- (IBAction)downloadAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction) onPlaySlider: (id) sender;


@property (weak, nonatomic) DSSong* song;
@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (strong, nonatomic)STKAudioPlayer *audioPlayer;
@property (strong, nonatomic)AVAudioPlayer *AVaudioPlayer;
@property (strong, nonatomic)NSTimer* playTimer;
@property (assign, nonatomic   ) BOOL isFavorite;
@property (assign, nonatomic   ) BOOL isPlaying;

@end
