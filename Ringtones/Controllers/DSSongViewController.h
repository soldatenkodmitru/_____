//
//  DSSongViewController.h
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "ViewController.h"
#import "DSSong.h"
#import <AVFoundation/AVFoundation.h>

@interface DSSongViewController : ViewController

@property (weak, nonatomic) DSSong* song;

@property (strong, nonatomic)AVAudioPlayer *audioPlayer;

@end
