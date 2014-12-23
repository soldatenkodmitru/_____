//
//  DSSong.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSong.h"

@implementation DSSong

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
      //  self.pr_id = [[responseObject objectForKey:@"id"]stringValue] ;
      //  self.img = [responseObject objectForKey:@"img"];
     //   self.text = [responseObject objectForKey:@"text"];
       // self.title = [responseObject objectForKey:@"title"];
        self.id_sound = [responseObject objectForKey:@"img"];
        @property (strong,nonatomic) NSString *artist;
        @property (strong,nonatomic) NSString *album;
        @property (strong,nonatomic) NSString *albumLink;
        @property (strong,nonatomic) NSString *year;
        @property (assign,nonatomic) float *rating;
        @property (strong,nonatomic) NSString *fileLink;
        @property (strong,nonatomic) NSString *fileDuration;
        @property (strong,nonatomic) NSString *ringtonLink;
        @property (strong,nonatomic) NSString *ringtonDuration;
        @property (strong,nonatomic) NSString *fileFullLink;
        @property (strong,nonatomic) NSString *fileFullDuration;
    }
    return self;
}

@end

/*Request: {"command":"GETSOUNDSLIST","param":{"filter":"eng"}}
 Response: {"param":[{"id_sound":1,"artist":"30 Second","title":"Music","album":"Yeah","album_link":"http://192.168.1.110:8085/resources/1/image1.jpg","year":1984,"language":"eng","rating":0.0,"download_count":0,"is_available":1,"files":{"rington":{"id_file":3,"file_link":"http://192.168.1.110:8085/resources/1/file3.m4r","date_create":"2014-12-22 14:58:03.0","size":1478,"duration":"00:05:00"},"cut":{"id_file":2,"file_link":"http://192.168.1.110:8085/resources/1/file2.m4r","date_create":"2014-12-22 14:56:04.0","size":4578,"duration":"00:03:00"},"full":{"id_file":1,"file_link":"http://192.168.1.110:8085/resources/1/50Cent.m4r","date_create":"2014-12-22 14:54:10.0","size":1478,"duration":"00:02:00"}}}]}*/



