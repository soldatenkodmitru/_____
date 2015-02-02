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
    self.downloadBtn.highlighted = NO;
    
    self.playBtn.selected = YES;
    self.stopBtn.selected = NO;
   
    
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
    
    if (self.stopBtn.selected){
        [self.streamer stop];
        self.playBtn.selected = YES;
        self.stopBtn.selected = NO;
        [self.playProgress setProgress: 0 animated:NO];
    }
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
    if ( [[DSDataManager dataManager] findSongForPlaylistName:@"Избранное" song:self.song] >0 )
        self.favoriteBtn.selected = YES;
    else
        self.favoriteBtn.selected = NO;
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

- (IBAction)stopAction:(id)sender{
   
    [self stop];
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

- (IBAction)favoriteAction:(id)sender {
  
    self.favoriteBtn.selected = !self.favoriteBtn.selected;
  
    if (self.favoriteBtn.selected){
        [[DSDataManager dataManager] addPlaylistItemForNameList:@"Избранное" song:self.song version:self.self.song.versionAudio fileLink:[self download:@"Избранное"] imagelink:[self saveImage]];
    }
    else{
        double idItem = [[DSDataManager dataManager] findSongForPlaylistName:@"Избранное" song:self.song];
        [[DSDataManager dataManager] deletePlaylistItemWithId:idItem];
        
    }
    }

- (IBAction)downloadAction:(id)sender {
    
    NSString* listName;
    switch (self.song.versionAudio) {
        case sFull:{
            listName = @"Загрузки";
            break;
        }
        case sCut:{
            listName = @"Рингтоны";
            break;
        }
        case sRignton:{
            listName = @"Рингтоны";
            break;
        }
    }

    if ([[DSDataManager dataManager] findSongForPlaylistName:listName song:self.song] == 0 ) {
            [[DSDataManager dataManager] addPlaylistItemForNameList:listName song:self.song version:self.song.versionAudio fileLink:[self download:listName] imagelink:[self saveImage]];
    }
    else {
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Данный трек уже присутствует в списке загрузок" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ок",nil];
        [alertView show];
    }

}

-(NSString*) saveImage{
    
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.song.albumLink lastPathComponent]];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(self.pictureSong)];
    [data writeToFile:fullPath atomically:YES];
    return fullPath;
    
}

-(NSString*) download:(NSString*)folderName {
 
    NSURLRequest *request = [NSURLRequest requestWithURL:self.song.audioFileURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory =[ documentsDirectory stringByAppendingPathComponent:folderName] ;
    
    BOOL isDir;
    NSFileManager *fileManager= [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", documentsDirectory);

    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[[self.song.audioFileURL lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
          //  NSLog(@"%@, %@",fullPath,[NSString stringWithFormat:@"%lld", fileSize]);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Загрузка прервана"
                                                            message:@"Соединение с сервером потеряно! Попробуйте пожалуйста скачать еще раз!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Oк"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];
    return fullPath;
}

#pragma mark - Purchaise

-(void)unlockFeatureForDate:(NSDate*) date {
    
   // [app showIndecator:NO withView:app.window];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"isPurchaise"];
    [defaults removeObjectForKey:@"isPurchaiseTermin"];
    [defaults removeObjectForKey:@"isPurchaiseDate"];
    [defaults synchronize];
    
    NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSString* dateStr = [objDateFormatter stringFromDate:date];
    NSNumber* term = nil;
    
    [defaults setObject:dateStr forKey:@"isPurchaiseDate"];
    [defaults setObject:term forKey:@"isPurchaiseTermin"];
    [defaults setBool:YES forKey:@"isPurchaise"];
    [defaults synchronize];
    //app.isPurchaise = YES;
    
   // [self prepareView];
    
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Сообщение" message:@"Ваши покупки успешно завершены" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alert show];
    
}


@end
