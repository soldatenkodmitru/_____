//
//  DSSongViewController.m
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSongViewController.h"
#import "AFNetworking.h"


@interface DSSongViewController ()

@end

@implementation DSSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
  
    self.downloadBtn.layer.cornerRadius=6.0;
    self.favoriteBtn.layer.cornerRadius=6.0;
    self.titleLabel.text=self.song.title;
    
    self.lblStartTime.text = @"00:00";
    self.lblEndTime.text = @"-00:00";
    [self.sldPlay setValue: 0.0f animated:YES];
    self.progDownload.hidden = YES;
    self.sldPlay.hidden = NO;

 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playAction:(id)sender {
    
    if (!self.isPlaying){
     
        self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updatePlayTime) userInfo:nil repeats:YES];
        
        if (self.audioPlayer == nil) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
         //   NSData *songData=[NSData dataWithContentsOfURL:[NSURL URLWithString:self.song.fileLink ]];
            self.audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
            self.audioPlayer.meteringEnabled = YES;
            self.audioPlayer.volume = 1;
            self.audioPlayer.delegate = self;
            [self.audioPlayer play:self.song.fileLink];
            self.lblEndTime.text = [NSString stringWithFormat:@"-%@", [self changeTimetoFloat:self.audioPlayer.duration]];
            [self.sldPlay setMaximumValue: self.audioPlayer.duration];
        }
        else
        {
            [self.audioPlayer resume];
        }
        
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        self.isPlaying=!self.isPlaying;
    }
    else{
        [self.playTimer invalidate];
        [self.audioPlayer pause];
    
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        self.isPlaying=!self.isPlaying;
    }

}

- (void) updatePlayTime
{
    
    //    NSLog(@"current time = %f", audioPlayer.currentTime);
    NSString* strPlayedTime = [self changeTimetoFloat: self.audioPlayer.progress];
    
    float fRemainTime = self.audioPlayer.duration -self.audioPlayer.progress;
    NSString* strRemainTime = [NSString stringWithFormat: @"-%@", [self changeTimetoFloat: fRemainTime]];
    
    [self.sldPlay setValue: self.audioPlayer.progress animated:YES];
    [self.lblStartTime setText: strPlayedTime];
    [self.lblEndTime setText: strRemainTime];
}

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
- (IBAction) onPlaySlider: (id) sender
{
    [self.audioPlayer seekToTime: self.sldPlay.value];
}
- (IBAction)downloadAction:(id)sender {
   
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.song.fileLink]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [ documentsDirectory stringByAppendingPathComponent:[self.song.fileLink lastPathComponent]];

    //NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.song.fileLink lastPathComponent]];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
          //  [[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
            NSLog(@"%@, %@",fullPath,[NSString stringWithFormat:@"%lld", fileSize]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];

}


/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{};
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{};
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{};
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{

    [self.playTimer invalidate];
    self.playTimer = nil;
    self.lblStartTime.text = @"00:00";
    self.lblEndTime.text = [NSString stringWithFormat:@"-%@", [self changeTimetoFloat:self.audioPlayer.duration]];
    
    [self.sldPlay setValue:0 animated:YES];
    self.isPlaying = NO;
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];



};
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{};

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

@end
