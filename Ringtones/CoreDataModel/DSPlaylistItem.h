//
//  DSPlaylistItem.h
//  Ringtones
//
//  Created by Дима on 04.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSPlaylist;

@interface DSPlaylistItem : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * id_song;
@property (nonatomic, retain) NSNumber * ord_no;
@property (nonatomic, retain) NSString * image_savefile_link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * savefile_link;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) DSPlaylist *owner;

@end
