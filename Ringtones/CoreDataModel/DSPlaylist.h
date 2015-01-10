//
//  DSPlaylist.h
//  Ringtones
//
//  Created by Дима on 04.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DSPlaylistItem;

@interface DSPlaylist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *item;
@end

@interface DSPlaylist (CoreDataGeneratedAccessors)

- (void)addItemObject:(DSPlaylistItem *)value;
- (void)removeItemObject:(DSPlaylistItem *)value;
- (void)addItem:(NSSet *)values;
- (void)removeItem:(NSSet *)values;

@end
