//
//  DSPlaylistViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSSoundManager.h"
#import "DSPlaylistViewController.h"
#import "ActionSheetStringPicker.h"
#import "NFXIntroViewController.h"
#import "DaiVolume.h"
#import "GMDCircleLoader.h"

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
     self.imageSong.image =  [UIImage imageNamed:@"grey_fon.png"];
    [self updateElements];
    [self.playProgress setTransform:CGAffineTransformMakeScale(1.0, 5)];
    self.shareBtn.highlighted = NO;
    
    self.titleLbl.text = self.song.title;
    self.artistLbl.text = self.song.artist;
    
    self.startLbl.text = @"00:00";
    self.endLbl.text = @"00:00";
   
    [DSSoundManager sharedManager].delegate = self;
    self.volumeProgress.progress = [DaiVolume volume];
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView transitionWithView:self.imageSong
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageSong.image =[self imageByScalingAndCroppingForSize:self.imageSong.bounds.size];
                    } completion:NULL];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [DSSoundManager sharedManager].delegate = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - DSSoundManagerDelegate

- (void) activeSongDidChange:(DSSong*)song{
    
    [self.playProgress setProgress:0 animated:NO];
    self.song = song;
    [self updateElements];
    [self animateElements];
    
}

- (void) statusChanged:(BOOL)playStatus{
    
    if (playStatus == NO) {
        self.playBtn.selected = YES;
        self.pauseBtn.selected = NO;

    }
}
#pragma mark - Self Methods

- (void) updateElements {
    
   
    self.navigationItem.title = [NSString stringWithFormat:@"%d из %d",[DSSoundManager sharedManager].activeIndex + 1,[[DSSoundManager sharedManager].playlist.songsArray count] ];
    
    if([DSSoundManager sharedManager].isPlaying == YES){
        self.playBtn.selected = NO;
        self.pauseBtn.selected = YES;
    }
    else{
        self.pauseBtn.selected = NO;
        self.playBtn.selected = YES;
    }
    
}

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


- (void) play{
    
    if (self.playBtn.selected){
        
        [[DSSoundManager sharedManager] play];
        self.pauseBtn.selected = YES;
        self.playBtn.selected = NO;

    }
}

- (void) animateElements {
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.song.saveImageLink]];
    if (data!=nil) {
        self.pictureSong = [UIImage imageWithData:data];
    }
    else{
        self.pictureSong = [UIImage imageNamed:@"default_fon.png"];
    }
    self.pictureSong = [self imageByScalingAndCroppingForSize:self.imageSong.bounds.size];
    [self setPicture];
    [self setLabel:self.titleLbl text:self.song.title];
    [self setLabel:self.artistLbl text:self.song.artist];
}

- (void) setLabel:(UILabel*) label  text:(NSString*)text{
    
    [UIView transitionWithView: label
                      duration:0.30f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        label.text = text;
                    } completion:NULL];
    
}
- (void) setPicture {
    
  
    [UIView transitionWithView:self.imageSong
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageSong.image = self.pictureSong;
                    } completion:NULL];


}
- (NSString*) timeToString:(double )timeInterval {
    float min = floor(timeInterval/60);
    float sec = round(timeInterval - min * 60);
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", (int)min, (int)sec];
    return time;
}



#pragma mark - Timer
- (void) timerAction:(id)timer{
    [self updatePlayTime];
}

- (void) updatePlayTime
{
    self.volumeProgress.progress = [DaiVolume volume];
    self.endLbl.text = [self timeToString:[DSSoundManager sharedManager].streamer.duration];
    self.startLbl.text = [self timeToString:[DSSoundManager sharedManager].streamer.currentTime];
   // NSLog(@"%f %f   %f" ,self.playProgress.progress,[DSSoundManager sharedManager].streamer.currentTime, [DSSoundManager sharedManager].streamer.duration);
    if ([DSSoundManager sharedManager].streamer.duration > 0  )
        [self.playProgress setProgress: (float)([DSSoundManager sharedManager].streamer.currentTime/[DSSoundManager sharedManager].streamer.duration)  animated:YES];
   
}


- (IBAction)playAction:(id)sender{
   
    [self play];
}


- (IBAction)pauseAction:(id)sender{
    
    [[DSSoundManager sharedManager] pause];
    if (self.pauseBtn.selected){
        self.playBtn.selected = YES;
        self.pauseBtn.selected = NO;
    }
}
- (IBAction)forwardAction:(id)sender{
    [[DSSoundManager sharedManager] forward];
   
}
- (IBAction)backAction:(id)sender{
    
    [[DSSoundManager sharedManager] backward];

}



- (IBAction)shareAction:(id)sender{
    UIImage *sendImage = self.pictureSong;
    UIButton* but = sender;
    [but setHighlighted:YES];
    CGRect rect;
    rect = self.view.bounds;
    rect.size.height = rect.size.height+200.f;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [GMDCircleLoader setOnView:self.view withRect:rect animated:YES];
    dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);
    // send initialization of UIActivityViewController in background
    dispatch_async(queue, ^{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[[NSString stringWithFormat:@"Лучшие рингтоны! Скачай %@ - %@ на свой телефон! itunes.apple.com/ru/artist/bestapp-studio-ltd./id739061892?l=ru",self.song.artist,self.song.title], sendImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [GMDCircleLoader hideFromView:self.view animated:YES];
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    });
    });
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self.pictureSong;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}








@end
