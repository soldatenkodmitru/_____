//
//  DSDataManager.m
//  Ringtones
//
//  Created by Dima on 12/28/14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//


#import "DSDataManager.h"
#import "DSLikesSong.h"
#import "DSPlaylistPlayer.h"


@implementation DSDataManager


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (DSDataManager*) dataManager{
    
    static DSDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        manager = [[DSDataManager alloc]init];
    });
    
    return manager;
}

- (NSMutableArray*) allPlaylists {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylist"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name != %@ ", @"Избранное"];
    NSSortDescriptor* idDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [request setSortDescriptors:@[idDescriptor]];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    NSMutableArray* playlists = [[NSMutableArray alloc] init];
    for (DSPlaylist* list in resultArray) {
        
        DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] initWithDatabase:list];
        if (playlist.name != nil)
            [playlists addObject:playlist];
    }
    return playlists;
}
- (DSPlaylist*) addPlaylistwithName:(NSString*) name{
    NSError* error = nil;
    
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                         inManagedObjectContext:self.managedObjectContext];
    NSDate* date = [NSDate date];
    curPlaylist.id =[NSNumber numberWithDouble:[date timeIntervalSince1970]];
    curPlaylist.name = name;

    if (![self.managedObjectContext save:&error]) {
        
       NSLog(@"%@", [error localizedDescription]);
       return nil;
    }
    else{
       return curPlaylist;
    }
    
}

- (void) addPlaylistItem:(NSString*) playList song:(DSSong*)  song version:(NSInteger) version fileLink:(NSString*) savefile_link  imagelink:(NSString*) imagelink{
    NSError* error = nil;
    
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                            inManagedObjectContext:self.managedObjectContext];
    DSPlaylistItem* curPlaylistItem = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylistItem"
                                                                    inManagedObjectContext:self.managedObjectContext];
    curPlaylist = [self findPlaylistWithName:playList];
    
    if(curPlaylist!=nil){
        NSDate* date = [NSDate date];
       
    
        curPlaylistItem.id_song = [NSNumber numberWithInteger: song.id_sound];
        curPlaylistItem.id =[NSNumber numberWithDouble:[date timeIntervalSince1970]];
        curPlaylistItem.version = [NSNumber numberWithInteger: version];
        curPlaylistItem.savefile_link = savefile_link;
        curPlaylistItem.image_savefile_link =imagelink;
        curPlaylistItem.artist = song.artist;
        curPlaylistItem.name = song.title;
    
        [curPlaylist addItemObject:curPlaylistItem];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        };
    }
}

- (DSPlaylist*) findPlaylistWithId:(double) listId {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylist"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@ ",[ NSNumber numberWithDouble:listId]];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    if ([resultArray count] != 0)
        return [resultArray objectAtIndex:0];
    else
        return nil;
}
- (DSPlaylist*) findPlaylistWithName:(NSString*) name {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylist"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name == %@ ", name];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    if ([resultArray count] != 0)
        return [resultArray objectAtIndex:0];
    else
        return nil;
}

- (BOOL) deletePlaylistWithId:(double) ItemId{
    NSError* error = nil;
    DSPlaylist* item = [self findPlaylistWithId:ItemId];
    
    [self.managedObjectContext deleteObject:item];
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    else{
        return YES;
    }

}
- (BOOL) deletePlaylistItemWithId:(double) ItemId{
    NSError* error = nil;
    DSPlaylistItem* item = [self findPlaylistItemWithId:ItemId];
    
    [self.managedObjectContext deleteObject:item];
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    else{
        return YES;
    }
    
}
- (DSPlaylistItem*) findPlaylistItemWithId:(double) itemId {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylistItem"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@ ",[ NSNumber numberWithDouble:itemId]];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    if ([resultArray count] != 0)
        return [resultArray objectAtIndex:0];
    else
        return nil;
}
-(NSMutableArray*) getSongsFromPalylistName:(NSString*) playList{
    
    NSMutableArray* objectsArray = [NSMutableArray array];
   
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                            inManagedObjectContext:self.managedObjectContext];
    curPlaylist = [self findPlaylistWithName:playList];
    NSArray* items = [curPlaylist.item allObjects];
    for (DSPlaylistItem* item in items) {
        DSSong* song = [[DSSong alloc] initWithDatabase:item];
        [objectsArray addObject:song];
    }
    return objectsArray;
}

- (void) addLikeForSong:(NSInteger)id_song {
    
    NSError* error = nil;
    
    DSLikesSong* curSong = [NSEntityDescription insertNewObjectForEntityForName:@"DSLikesSong"
                                                         inManagedObjectContext:self.managedObjectContext];
    
    curSong.id_song = [NSNumber numberWithInteger:id_song];
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    };
    
}

- (bool) existsLikeForSong:(NSInteger) id_song {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSLikesSong"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_song == %d ", id_song];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    if ([resultArray count] > 0){
        return YES;
    }
    else {
        return NO;
    }
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "BestAppStudio.Ringtones" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Ringtones" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    NSURL *storeURL =  [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Ringtones.sqlite"];
    

    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;

    
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
@end
