//
//  DSPlaylistViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSPlaylistViewController.h"
#import "ActionSheetStringPicker.h"
#import "NFXIntroViewController.h"
#import "DaiVolume.h"


static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@implementation DSPlaylistViewController


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
    

 
    
    self.titleLbl.text = self.song.title;
    self.artistLbl.text = self.song.artist;
    self.imageSong.image = self.pictureSong;
    self.startLbl.text = @"00:00";
    self.endLbl.text = @"00:00";
   
    self.shareBtn.highlighted = NO;
   // self.downloadBtn.highlighted = NO;
    
    self.playBtn.selected = YES;
   // self.stopBtn.selected = NO;
   
    
    if (self.song.versionAudio == 0){
        self.song.versionAudio = sFull;
        self.song.audioFileURL = [NSURL URLWithString:self.song.fileLink];
    }
     [self setTitleVersion];
      self.volumeProgress.progress = [DaiVolume volume];
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
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
    
//    if (self.stopBtn.selected){
        [self.streamer stop];
        self.playBtn.selected = YES;
 //       self.stopBtn.selected = NO;
        [self.playProgress setProgress: 0 animated:NO];
   // }
}

- (void) playBackground{

    if ([self.thread isExecuting]) {
        [self.thread cancel];
    }
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(play) object:nil];
    self.thread.name = @"play";
    [self.thread start];

}

- (void) play{
    
    if (self.playBtn.selected){
        [self.playProgress setProgress: 0 animated:NO];
        [self resetStreamer];
        [self.streamer play];
      //  self.stopBtn.selected = YES;
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
   // if ( [[DSDataManager dataManager] findSongForPlaylistName:@"Избранное" song:self.song] >0 )
   //     self.favoriteBtn.selected = YES;
 //   else
     //   self.favoriteBtn.selected = NO;
}

#pragma mark - Timer
- (void) timerAction:(id)timer{
    [self updatePlayTime];
}

- (void) updatePlayTime
{
    self.volumeProgress.progress = [DaiVolume volume];
    self.endLbl.text = [self timeToString:self.streamer.duration];
    self.startLbl.text = [self timeToString:self.streamer.currentTime];
   // NSLog(@"%f   %f" ,self.streamer.currentTime, self.streamer.duration);
    if (self.streamer.duration > 0)
    {
        [self.playProgress setProgress: (float)(self.streamer.currentTime/self.streamer.duration)  animated:YES];
    }
}



#pragma mark - Implementation
- (void)versionWasSelected:(NSNumber *)selectedIndex element:(id)element {
    
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
    if (!self.playBtn.selected) {
        [self stop];
        [self playBackground];
        
    }
    [self setTitleVersion];
}
- (void)actionPickerCancelled:(id)sender {
   // NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

#pragma mark - Actions
- (IBAction)versionAction:(id)sender{
    
    [ActionSheetStringPicker showPickerWithTitle:@"Выберите версию" rows:[NSArray arrayWithObjects: @"Полная версия", @"Нарезка1",@"Нарезка2" , nil] initialSelection:self.song.versionAudio target:self successAction:@selector(versionWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (IBAction)playAction:(id)sender{
   
    [self playBackground];
}


- (IBAction)pauseAction:(id)sender{
    
}
- (IBAction)forwardAction:(id)sender{
    
}
- (IBAction)backAction:(id)sender{
    
}
- (IBAction)recoendedAction:(id)sender{
    
}


- (IBAction)shareAction:(id)sender{
    UIImage *sendImage = self.pictureSong;
    self.shareBtn.highlighted = YES;
    dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);
    // send initialization of UIActivityViewController in background
    dispatch_async(queue, ^{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[[NSString stringWithFormat:@"Лучшие рингтоны! Скачай %@ - %@ на свой телефон! itunes.apple.com/ru/artist/bestapp-studio-ltd./id739061892?l=ru",self.song.artist,self.song.title], sendImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    });
    });
}










@end
