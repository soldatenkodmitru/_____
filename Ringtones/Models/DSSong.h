//
//  DSSong.h
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSSong : NSObject

//@property (strong,nonatomic) NSString *pr_id;
//@property (strong,nonatomic) NSString *img;
//@property (strong,nonatomic) NSString *text;
//@property (strong,nonatomic) NSString *title;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;


@end
