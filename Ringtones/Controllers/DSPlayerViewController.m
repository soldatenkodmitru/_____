//
//  DSPlayerViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSPlayerViewController.h"
#import "ActionSheetStringPicker.h"
#import "NFXIntroViewController.h"
#import "DaiVolume.h"


static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@implementation DSPlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    

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
   
    self.shareBtn.highlighted = NO;
    self.downloadBtn.highlighted = NO;
    
    self.playBtn.selected = YES;
    self.stopBtn.selected = NO;
   
    if ( [[DSDataManager dataManager] findSongForPlaylistName:@"Избранное" song:self.song] >0 )
        self.favoriteBtn.selected = YES;
    else
        self.favoriteBtn.selected = NO;
    if (self.song.versionAudio == 0)
        self.song.versionAudio = sFull;
     [self setTitleVersion];
      self.volumeProgress.progress = [DaiVolume volume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [self.streamer stop];
    [self cancelStreamer];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Self Methods
- (void) showInstruction {
    
    UIImage*i1 = [UIImage imageNamed:@"1.png"];
    UIImage*i2 = [UIImage imageNamed:@"2.png"];
    UIImage*i3 = [UIImage imageNamed:@"3.png"];
    UIImage*i4 = [UIImage imageNamed:@"4.png"];
    UIImage*i5 = [UIImage imageNamed:@"5.png"];
    UIImage*i6 = [UIImage imageNamed:@"6.png"];
    UIImage*i7 = [UIImage imageNamed:@"7.png"];
    UIImage*i8 = [UIImage imageNamed:@"8.png"];
    UIImage*i9 = [UIImage imageNamed:@"9.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3,i4,i5,i2,i6,i7,i8,i9]];
    [self presentViewController:vc animated:true completion:nil];
    
}

- (void) stop {
    if (self.stopBtn.selected){
        [self.streamer stop];
        self.playBtn.selected = YES;
        self.stopBtn.selected = NO;
        [self.playProgress setProgress: 0 animated:NO];
    }
}

- (void) playBackground{

    [self play];

}

- (void) play{
    
    
    if (self.playBtn.selected){
        [self.playProgress setProgress: 0 animated:NO];
        [self resetStreamer];
        [self.streamer play];
        self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayTime) userInfo:nil repeats:YES];
        self.stopBtn.selected = YES;
        self.playBtn.selected = NO;
        
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

- (void) resetStreamer
{
    [self cancelStreamer];
    
    if (self.song.audioFileURL == nil){
        self.song.audioFileURL = [NSURL URLWithString: self.song.fileLink];
    }
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

- (void) setTitleVersion {
    switch (self.song.versionAudio){
        case sFull:
            [self.versionBtn setTitle: @"Полная версия     " forState:UIControlStateNormal];
             break;
        case sCut:
            [self.versionBtn setTitle: @"Нарезка 1     " forState:UIControlStateNormal];
            break;
        case sRignton:
            [self.versionBtn setTitle: @"Нарезка 2     " forState:UIControlStateNormal];
            break;
    }
    
}

#pragma mark - Timer
- (void) updatePlayTime
{
    
    self.volumeProgress.progress = [DaiVolume volume];
    self.endLbl.text = [self timeToString:self.streamer.duration];
    self.startLbl.text = [self timeToString:self.streamer.currentTime];
    if (self.streamer.duration > 0)
    {
        [self.playProgress setProgress: (float)(self.streamer.currentTime/self.streamer.duration)  animated:YES];
    }
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
#pragma mark - Implementation

- (void)animalWasSelected:(NSNumber *)selectedIndex element:(id)element {
     self.song.versionAudio = [selectedIndex intValue];
    switch(self.song.versionAudio){
        case sFull:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.fileLink];
        break;}

        case sCut:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.cutLink];
        break;}
        case sRignton:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.ringtonLink];
        break;}
    }
    [self stop];
    [self playBackground];
    [self setTitleVersion];
    
}
- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}
#pragma mark - Actions
- (IBAction)versionAction:(id)sender{
    
     [ActionSheetStringPicker showPickerWithTitle:@"Выберите версию" rows:[NSArray arrayWithObjects: @"Полная версия", @"Нарезка1",@"Нарезка2" , nil] initialSelection:self.song.versionAudio target:self successAction:@selector(animalWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
}


- (IBAction)playAction:(id)sender{
    
    if ([self.thread isExecuting]) {
        [self.thread cancel];
    }
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(playBackground) object:nil];
    self.thread.name = @"play";
    [self.thread start];
    
}
- (IBAction)stopAction:(id)sender{
    [self stop];
}

- (IBAction)shareAction:(id)sender{
    UIImage *sendImage = self.pictureSong;
    self.shareBtn.highlighted = YES;
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[@"Best rigtones http:\\google.com", sendImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}
- (IBAction)favoriteAction:(id)sender {
  
    if (!self.favoriteBtn.selected){
        [[DSDataManager dataManager] addPlaylistItemForNameList:@"Избранное" song:self.song version:sFull fileLink:[self download] imagelink:[self saveImage]];
    }
    else{
        double idItem = [[DSDataManager dataManager] findSongForPlaylistName:@"Избранное" song:self.song];
        [[DSDataManager dataManager] deletePlaylistItemWithId:idItem];
        
    }
    self.favoriteBtn.selected = !self.favoriteBtn.selected;
}
- (IBAction)downloadAction:(id)sender {
    
    if ([[DSDataManager dataManager] findSongForPlaylistName:@"Загрузки" song:self.song] > 0 || [[DSDataManager dataManager] findSongForPlaylistName:@"Рингтоны" song:self.song] ){
        switch (self.song.versionAudio) {
            case sFull:{
                [[DSDataManager dataManager] addPlaylistItemForNameList:@"Загрузки" song:self.song version:sFull fileLink:[self download] imagelink:[self saveImage]];
            break;
            }
            case sCut:{
            
                [[DSDataManager dataManager] addPlaylistItemForNameList:@"Рингтоны" song:self.song version:sCut fileLink:[self download] imagelink:[self saveImage]];
            break;
            }
            case sRignton:{
                    [[DSDataManager dataManager] addPlaylistItemForNameList:@"Рингтоны" song:self.song version:sRignton fileLink:[self download] imagelink:[self saveImage]];
            break;
                }
        }
    }
    else{
        
    }
        
  }
-(NSString*) saveImage{
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.song.albumLink lastPathComponent]];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(self.pictureSong)];
    [data writeToFile:fullPath atomically:YES];
    return fullPath;
    
}

-(NSString*) download {
 

    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.song.audioFileURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [ documentsDirectory stringByAppendingPathComponent:[self.song.fileLink lastPathComponent]];
    
    
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
