//
//  DSPlaylistItem.h
//  Ringtones
//
//  Created by Dima on 12/29/14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSPlaylistItem : NSManagedObject

@property (nonatomic, retain) NSNumber * id_song;
@property (nonatomic, retain) NSString * savefile_link;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSManagedObject *owner;

@end
