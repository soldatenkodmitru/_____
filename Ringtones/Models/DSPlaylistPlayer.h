//
//  DSPlaylistPlayer.h
//  Ringtones
//
//  Created by Дима on 31.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSPlaylist.h"
#import "DSDataManager.h"

@interface DSPlaylistPlayer : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSArray *songsArray;

- (instancetype)initWithDatabase:(DSPlaylist *) item ;
- (id)copyWithZone:(NSZone *)zone;

@end
