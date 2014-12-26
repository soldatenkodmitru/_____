//
//  DSSong.h
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface DSSong : NSObject <DOUAudioFile>

  @property (assign,nonatomic) NSInteger id_sound;
  @property (strong,nonatomic) NSString *title;
  @property (strong,nonatomic) NSString *artist;
  @property (strong,nonatomic) NSString *album;
  @property (strong,nonatomic) NSString *albumLink;
  @property (assign,nonatomic) NSInteger year;
  @property (assign,nonatomic) float  rating;
  @property (strong,nonatomic) NSString *cutLink;
  @property (strong,nonatomic) NSString *cutDuration;
  @property (strong,nonatomic) NSString *ringtonLink;
  @property (strong,nonatomic) NSString *ringtonDuration;
  @property (strong,nonatomic) NSString *fileLink;
  @property (strong,nonatomic) NSString *fileDuration;
  @property (nonatomic, strong) NSURL *audioFileURL;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;


@end

