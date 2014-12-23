//
//  DSSongViewController.m
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSongViewController.h"

@interface DSSongViewController ()

@end

@implementation DSSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    NSData *songData=[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.song.fileLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:songData error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
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

@end
