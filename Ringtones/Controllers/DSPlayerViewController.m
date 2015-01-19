//
//  DSPlayerViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSPlayerViewController.h"
#import "DaiVolume.h"


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
    [self.streamer play];
    
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayTime) userInfo:nil repeats:YES];
  
 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [self.streamer stop];
    [self cancelStreamer];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Self Methods


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

- (NSString*) timeToString:(double )timeInterval {
    float min = floor(timeInterval/60);
    float sec = round(timeInterval - min * 60);
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", (int)min, (int)sec];
    return time;
}

#pragma mark - Timer
- (void) updatePlayTime
{
    
    self.volumeProgress.progress = [DaiVolume volume];
    self.endLbl.text = [self timeToString:self.streamer.duration];
    self.startLbl.text = [self timeToString:self.streamer.currentTime];
    [self.playProgress setProgress: (float)(self.streamer.currentTime/self.streamer.duration)  animated:YES];
   
   
   
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
- (IBAction)favoriteAction:(id)sender {
    
    [[DSDataManager dataManager] addPlaylistItemForNameList:@"Избранное" song:self.song version:sFull fileLink:[self download] imagelink:@""];
    
}
- (IBAction)downloadAction:(id)sender {
    
    [[DSDataManager dataManager] addPlaylistItemForNameList:@"Загрузки" song:self.song version:sFull fileLink:[self download] imagelink:@""];
    
    
    
}

-(NSString*) download {
    // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.song.fileLink]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.song.fileLink]];
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
        
        //  NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            //  [[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
            //return fullPath;
            NSLog(@"%@, %@",fullPath,[NSString stringWithFormat:@"%lld", fileSize]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];
    return fullPath;
}

@end
