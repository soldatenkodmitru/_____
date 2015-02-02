//
//  DSPlaylistViewController.h
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//


#import "ViewController.h"
#import "DSSong.h"
#import "DSRateView.h"
#import "DSDataManager.h"
#import "DSServerManager.h"
#import "DOUAudioStreamer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DSPlaylistViewController : ViewController <DSRateViewDelegate>

- (IBAction)playAction:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)downloadAction:(id)sender;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)versionAction:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView* imageSong;
@property (strong, nonatomic) IBOutlet UIButton *versionBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) IBOutlet UIButton *stopBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *downloadBtn;
@property (strong, nonatomic) IBOutlet UILabel *artistLbl;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *startLbl;
@property (strong, nonatomic) IBOutlet UILabel *endLbl;
@property (strong, nonatomic) IBOutlet UIProgressView *playProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *volumeProgress;

@property (weak, nonatomic) DSSong* song;
@property (weak, nonatomic) UIImage* pictureSong;
@property (strong, nonatomic) DOUAudioStreamer *streamer;
@property (strong, nonatomic)   NSTimer* playTimer;
@property (strong, nonatomic)   NSThread* thread;
@property (assign, nonatomic   ) BOOL isFavorite;
@property (assign, nonatomic   ) BOOL isPlaying;
@end
