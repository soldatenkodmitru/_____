//
//  DSDataManager.h
//  Ringtones
//
//  Created by Dima on 12/28/14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) addLikeForSong:(NSInteger)id_song;
- (bool) existsLikeForSong:(NSInteger) id_song;

+ (DSDataManager*) dataManager;

@end
