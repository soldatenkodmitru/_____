//
//  DSLikesSong.h
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSLikesSong : NSManagedObject

@property (nonatomic, retain) NSNumber * id_song;
@property (nonatomic, retain) NSNumber * rating;

@end
