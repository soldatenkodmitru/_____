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
        
    }
    
    return self;
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


@end
