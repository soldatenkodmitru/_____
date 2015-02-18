//
//  DSDataManager.m
//  Ringtones
//
//  Created by Dima on 12/28/14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//


#import "DSDataManager.h"
#import "DSLikesSong.h"
#import  "NSManagedObjectContext+SRFetchAsync.h"


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
- (BOOL) ordNoWithPlaylist: (NSArray*) playlist{
    NSError* error = nil;
    int i =0 ;
    DSPlaylistItem* curPlaylistItem = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylistItem"
                                                                    inManagedObjectContext:self.managedObjectContext];
    for (DSSong* song in playlist){
         
        curPlaylistItem = [self findPlaylistItemWithId:song.songId];
        curPlaylistItem.ord_no = [NSNumber numberWithInt:i];
        i++;
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    };
    return YES;
}
-(NSMutableArray*) getSongsFromPalylistName:(NSString*) name{
    
    NSMutableArray* objectsArray = [NSMutableArray array];
    
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                            inManagedObjectContext:self.managedObjectContext];
    curPlaylist = [self findPlaylistWithName:name];
    NSArray* items = [curPlaylist.item allObjects];
    items = [self sortingSongs:items];
    for (DSPlaylistItem* item in items) {
        DSSong* song = [[DSSong alloc] initWithDatabase:item];
        [objectsArray addObject:song];
    }
    return objectsArray;
}
- (void) allPlaylistsOnSuccess:(void(^)(NSArray* songs, NSError* error)) success
{
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylist"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name != %@ ", @"Избранное"];
    NSSortDescriptor* idDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [request setSortDescriptors:@[idDescriptor]];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.managedObjectContext sr_executeFetchRequest:request completion:^(NSArray *objects, NSError *error) {
        NSMutableArray* playlists = [[NSMutableArray alloc] init];
        for (DSPlaylist* list in objects) {
            
            DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] initWithDatabase:list];
            if (playlist.name != nil)
                [playlists addObject:playlist];
        }
        if (success) {
            success(playlists, error );
        }

    }];
     
    });
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

- (double)  addPlaylistItemForIdList:(double) itemId song:(DSSong*)  song {
    NSError* error = nil;
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                            inManagedObjectContext:self.managedObjectContext];
    DSPlaylistItem* curPlaylistItem = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylistItem"
                                                                    inManagedObjectContext:self.managedObjectContext];
    curPlaylist = [self findPlaylistWithId:itemId];
    
    if(curPlaylist!=nil){
        NSDate* date = [NSDate date];
        
        double id_song = [date timeIntervalSince1970];
        curPlaylistItem.id_song = [NSNumber numberWithInteger: song.id_sound];
        curPlaylistItem.id = [NSNumber numberWithDouble:id_song];
        curPlaylistItem.version = [NSNumber numberWithInteger: song.versionAudio];
        curPlaylistItem.savefile_link = song.saveFileLink;
        curPlaylistItem.image_savefile_link = song.saveImageLink;
        curPlaylistItem.rate = [NSNumber numberWithFloat:song.rating];
        curPlaylistItem.artist = song.artist;
        curPlaylistItem.name = song.title;
        curPlaylistItem.original_link = song.fileLink;
        
        [curPlaylist addItemObject:curPlaylistItem];
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        };
        return id_song;
    }

    return 0;
    
}
- (void) addPlaylistItemForNameList:(NSString*) playList song:(DSSong*)  song    version:(NSInteger) version fileLink:(NSString*) savefile_link  imagelink:(NSString*) imagelink{
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
        switch (version){
            case sFull:{
                curPlaylistItem.original_link = song.fileLink;
                break;
            }
            case sCut:{
                curPlaylistItem.original_link = song.cutLink;
                break;
            }
            case sRignton:{
                curPlaylistItem.original_link = song.ringtonLink;
                break;
            }
        }
        
        curPlaylistItem.rate = [NSNumber numberWithFloat:song.rating];
        
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
    NSArray *items = [item.item allObjects];
    for(DSPlaylistItem* song in items){
        [self deletePlaylistItemWithId:[song.id doubleValue]];
    }
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
    if (item!=nil){
        [self.managedObjectContext deleteObject:item];
        if(![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        return NO;
        }
        else{
        [self removeFile: item.savefile_link];
        [self removeFile: item.image_savefile_link];
        return YES;
        }
    }
    return NO;
}


- (void)removeFile:(NSString *) filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"File deleted %@",filePath);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
- (double) findSongForPlaylistName:(NSString*) name song:(DSSong*) song{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"DSPlaylistItem"
                inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id_song == %@ AND version == %@",[ NSNumber numberWithInteger:song.id_sound], [NSNumber numberWithInteger:song.versionAudio]];
    
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSError* requestError = nil;
    NSArray* resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
    if (requestError) {
        NSLog(@"%@", [requestError localizedDescription]);
    }
    for(DSPlaylistItem* item in resultArray){
        if( [item.owner.name isEqualToString:name] ){
            return [item.id doubleValue];
        }
        
    }
    return 0;
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



-(NSMutableArray*) getSongsFromPalylistID:(double) itemId{
    
    NSMutableArray* objectsArray = [NSMutableArray array];
   
    DSPlaylist* curPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"DSPlaylist"
                                                            inManagedObjectContext:self.managedObjectContext];
    curPlaylist = [self findPlaylistWithId:itemId];
    NSArray* items = [curPlaylist.item allObjects];
    items = [self sortingSongs:items];
    for (DSPlaylistItem* item in items) {
        DSSong* song = [[DSSong alloc] initWithDatabase:item];
        [objectsArray addObject:song];
    }
    return objectsArray;
}

- (NSArray *)sortingSongs:(NSArray *)unsortedArray {
    NSArray* sortedArray;
    NSSortDescriptor *primary = [NSSortDescriptor sortDescriptorWithKey:@"ord_no" ascending:YES];
    NSSortDescriptor *secondary = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES ];
    sortedArray = [NSArray arrayWithArray:[unsortedArray sortedArrayUsingDescriptors:@[primary, secondary]]];
    return sortedArray;
}

- (void) addLikeForSong:(NSInteger)id_song withRating:(float) rating{
    
    NSError* error = nil;
    
    DSLikesSong* curSong = [NSEntityDescription insertNewObjectForEntityForName:@"DSLikesSong"
                                                         inManagedObjectContext:self.managedObjectContext];
    
    curSong.id_song = [NSNumber numberWithInteger:id_song];
    curSong.rating = [NSNumber numberWithFloat:rating];
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    };
    
}

- (float) existsLikeForSong:(NSInteger) id_song {
    
    DSLikesSong* curSong = [NSEntityDescription insertNewObjectForEntityForName:@"DSLikesSong"
                                                         inManagedObjectContext:self.managedObjectContext];

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
        curSong = [resultArray objectAtIndex:0];
        return [curSong.rating doubleValue] ;
    }
    else {
        return 0;
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
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
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
