//
//  DSSong.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSong.h"


@implementation DSSong

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
    
        self.id_sound = [[responseObject objectForKey:@"id_sound"]integerValue] ;
        self.title = [responseObject objectForKey:@"title"];
        self.artist = [responseObject objectForKey:@"artist"];
        self.album = [responseObject objectForKey:@"album"];
        self.albumLink = [responseObject objectForKey:@"album_link"];
        self.year = [[responseObject objectForKey:@"year"]integerValue];
        self.rating = [[responseObject objectForKey:@"rating"] floatValue];
        self.cutLink =[[[[responseObject objectForKey:@"files"] objectForKey:@"cut"] objectForKey:@"file_link"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.cutDuration = [[[responseObject objectForKey:@"files"] objectForKey:@"cut" ]objectForKey:@"duration"];
        self.ringtonLink =[[[[responseObject objectForKey:@"files"] objectForKey:@"rington"] objectForKey:@"file_link"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.ringtonDuration = [[[responseObject objectForKey:@"files"] objectForKey:@"rington"] objectForKey:@"duration"];
        self.fileLink =[[[[responseObject objectForKey:@"files"] objectForKey:@"full"] objectForKey:@"file_link"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.fileDuration = [[[responseObject objectForKey:@"files"] objectForKey:@"full"] objectForKey:@"duration"];
      
    }
    return self;
}

- (instancetype)initWithDatabase:(DSPlaylistItem *) item {
    
    self = [super init];
    if (self) {
        
       self.id_sound = [item.id_song integerValue];
       self.saveFileLink= item.savefile_link;
       self.version = item.version ;
       self.title = item.name;
       self.artist = item.artist;
       self.saveImageLink = item.image_savefile_link;
        
    }
    return self;
}

@end




