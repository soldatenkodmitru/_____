//
//  DSServerManager.h
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSServerManager : NSObject


+ (DSServerManager *)sharedManager;

- (void) getSongWithFilter:(NSString*) filter OnSuccess:(void(^)(NSArray* songs)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getSongWithDays:(NSString*) days OnSuccess:(void(^)(NSArray* songs)) success
                 onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) setSongRating:(NSString*) rating forSong:(NSString*) idSong OnSuccess:(void(^)(NSObject* result)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
