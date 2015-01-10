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
        
       self.songId = [item.id doubleValue];
       self.id_sound = [item.id_song integerValue];
       self.saveFileLink= item.savefile_link;
       self.versionAudio = (typeSong) [item.version integerValue];
       self.title = item.name;
       self.artist = item.artist;
       self.saveImageLink = item.image_savefile_link;
        
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setSongId:[self songId]];
    [copy setId_sound:[self id_sound]];
    [copy setTitle:[self title]];
    [copy setArtist:[self artist]];
    [copy setAlbum:[self album]];
    [copy setAlbumLink:[self albumLink]];
    [copy setYear:[self year]];
    [copy setRating:[self rating]];
    [copy setCutLink:[self cutLink]];
    [copy setCutDuration:[self cutDuration]];
    [copy setRingtonLink:[self ringtonLink]];
    [copy setRingtonDuration:[self ringtonDuration]];
    [copy setFileLink:[self fileLink]];
    [copy setFileDuration:[self fileDuration]];
    [copy setSaveFileLink:[self saveFileLink]];
    [copy setSaveImageLink:[self saveImageLink]];
    [copy setAudioFileURL:[self audioFileURL]];
    [copy setIsLocal:[self isLocal]];
    [copy setVersionAudio:[self versionAudio]];
 
    return copy;
}

@end




