//
//  DSMainViewController.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSMainViewController.h"
#import "DSSongViewController.h"
#import "DSServerManager.h"
#import "DSSong.h"
#import "UIImageView+AFNetworking.h"

@interface DSMainViewController ()

    @property (strong, nonatomic) NSArray* songsArray;
    @property (assign, nonatomic) NSInteger selectedItem;

@end

@implementation DSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getSongsFromServerWithFilter:@"eng"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - API

- (void) getSongsFromServerWithFilter:(NSString*) filter {
    
    [[DSServerManager sharedManager]getSongWithFilter:filter OnSuccess:^(NSArray *songs)
    {
        self.songsArray = [NSArray arrayWithArray:songs];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.songsArray count] ;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"song";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];}
    
    DSSong* song = [self.songsArray objectAtIndex:indexPath.row ];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.artist;
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:song.albumLink]];
    
    __weak UITableViewCell* weakCell = cell;
    
    cell.imageView.image = nil;
    
    [cell.imageView
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.imageView.image = image;
         [weakCell layoutSubviews];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"error = %@", [error localizedDescription]);
     }];
    
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedItem = indexPath.row;
    return indexPath;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DSSongViewController *dc = [segue destinationViewController];
    dc.song = [self.songsArray objectAtIndex:self.selectedItem];
    
}
#pragma mark -  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    
    switch (item.tag)
    {
        case 1:
            
            [self getSongsFromServerWithFilter:@"eng"];
            
            break;
        case 2:
            
            [self getSongsFromServerWithFilter:@"rus"];
       
            break;
        case 3:
            
             [self getSongsFromServerWithFilter:@"new"];
            
            break;
        case 4:
            break;
        case 5:
            
            break;
            
    }
  
}


@end
