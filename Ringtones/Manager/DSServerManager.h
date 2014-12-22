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

- (void) getSongTopEngWithFilter:(NSString*) filter OnSuccess:(void(^)(NSArray* songs)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
