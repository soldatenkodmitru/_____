//
//  DSPlaylistPlayer.m
//  Ringtones
//
//  Created by Дима on 31.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSPlaylistPlayer.h"

@implementation DSPlaylistPlayer

- (instancetype)initWithDatabase:(DSPlaylist *) item {
    
    self = [super init];
    if (self) {
        
        self.name= item.name;
        self.songsArray  = [[DSDataManager dataManager] getSongsFromPalylistName:item.name];
        
    }
    return self;
}

  

@end
