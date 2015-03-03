//
//  DSServerManager.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSong.h"
#import "DSServerManager.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationLogger.h"



@interface  DSServerManager()

@property (strong,nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

@end


@implementation DSServerManager


+ (DSServerManager *)sharedManager {
    
    static DSServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DSServerManager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@"http://195.138.68.2:8085/"]];
        [self.requestOperationManager.reachabilityManager startMonitoring];
    }
    
    return self;
}


- (BOOL) reachability{
   return self.requestOperationManager.reachabilityManager.reachable;
}

- (void) getSongWithPlaylist:(NSString*) list OnSuccess:(void(^)(NSArray* songs)) success
                 onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    
    self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer ];
    
    self.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"GETSOUNDSLIST" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys:@"fav", @"filter",list, @"list", nil],@"param", nil];
    
    
    //[[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in responseObject) {
             DSSong* song = [[DSSong alloc] initWithDictionary:dict];
             [objectsArray addObject:song];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}


- (void) getSongWithFilter:(NSString*) filter OnSuccess:(void(^)(NSArray* songs)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
   
   
     self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer ];
    
    self.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"GETSOUNDSLIST" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys:filter, @"filter",nil],@"param", nil];
    
      
   //[[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in responseObject) {
             DSSong* song = [[DSSong alloc] initWithDictionary:dict];
             [objectsArray addObject:song];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

- (void) getSongWithDays:(NSString*) days OnSuccess:(void(^)(NSArray* songs)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{

    self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer ];
    
    self.requestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"GETSOUNDSLIST" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys:@"new", @"filter",days,@"term",nil],@"param", nil];
    
    
   
   // success([self getsongs]);
    //[[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in responseObject) {
             DSSong* song = [[DSSong alloc] initWithDictionary:dict];
             [objectsArray addObject:song];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

-(NSArray*) getsongs{
 
    DSSong *song = [[DSSong alloc] init];
    song.id_sound  = 1;
    song.artist = @"Artist";
    song.rating = 3.0;
    song.title = @"song";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"album" ofType:@"jpeg"];
    song.albumLink = path;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"album" ofType:@"mp3"];
    song.fileLink = path1;
    DSSong *song1 = [[DSSong alloc] init];
    song1.id_sound = 2;
    song1.artist = @"Potap";
    song1.rating = 2.0;
    song1.title = @"kamen";
    path = [[NSBundle mainBundle] pathForResource:@"potap" ofType:@"jpeg"];
    song1.albumLink = path;
    path1 = [[NSBundle mainBundle] pathForResource:@"potap" ofType:@"mp3"];
    song1.fileLink = path1;
    DSSong *song2 = [[DSSong alloc] init];
    song2.id_sound = 3;
    song2.artist = @"Creed";
    song2.rating = 4.0;
    song2.title = @"Creed";
    path = [[NSBundle mainBundle] pathForResource:@"kreed" ofType:@"jpeg"];
    song2.albumLink = path;
    path1 = [[NSBundle mainBundle] pathForResource:@"kreed" ofType:@"mp3"];
    song2.fileLink = path1;
    NSArray *array = [NSArray arrayWithObjects: song, song1, song2, nil];
    return (array);
}

- (void) setSongRating:(NSString*) rating forSong:(NSString*) idSong OnSuccess:(void(^)(NSObject* result)) success
             onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{

    self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer ];
   
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"SETRATING" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys: idSong, @"id_sound",rating,@"rating",nil],@"param", nil];
    //id obj ;
    
   // success(obj);
    
   // [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
   [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }]; 
    
}

- (void) setDownloadForFile:(NSString*) idFile OnSuccess:(void(^)(NSObject* result)) success
             onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure{
    
    self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer ];
    
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"SETDOWNLOAD" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys: idFile, @"id_file",nil],@"param", nil];
    //id obj ;
    
    // success(obj);
    
    // [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"JSON: %@", responseObject);
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}




@end
