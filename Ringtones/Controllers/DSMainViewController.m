//
//  DSMainViewController.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSMainViewController.h"
#import "DSSongViewController.h"
#import "DSSongTableViewCell.h"
#import "DSHeaderTableViewCell.h"
#import "DSRateView.h"
#import "DSServerManager.h"
#import "DSPlaylistPlayer.h"
#import "DSSong.h"
#import "UIImageView+AFNetworking.h"
#import "DSPlaylistItem.h"
#import "DSDataManager.h"

@interface DSMainViewController ()

    @property (strong, nonatomic) UIBarButtonItem* item;
    @property (strong, nonatomic) NSMutableArray* playlistArray;
    @property (assign, nonatomic) NSInteger selectedSection;
    @property (assign, nonatomic) NSInteger selectedItem;
    @property (assign, nonatomic) NSInteger selectedPeriod;
@end

@implementation DSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getSongsFromServerWithFilter:@"rus"];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.selectedPeriod = 0;
    [self setDefaultPlaylists];
    self.playlistArray = [[NSMutableArray alloc] init];
    self.item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist:)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setDefaultPlaylists{
    
    if([[DSDataManager dataManager] findPlaylistWithName:@"Загрузки"]==nil)
    {
        [[DSDataManager dataManager] addPlaylistwithName:@"Загрузки"];
        [[DSDataManager dataManager] addPlaylistwithName:@"Рингтоны"];
        [[DSDataManager dataManager] addPlaylistwithName:@"Избранное"];
    }
}

#pragma mark - API

- (void) getPlaylistSongs{
    [self.playlistArray removeAllObjects];
    self.playlistArray = [[DSDataManager dataManager] allPlaylists];
     [self.tableView reloadData];
}

- (void) getFavoriteSongs{
    
    [self.playlistArray removeAllObjects];
    DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
    playlist.name = @"Избранное";
    playlist.songsArray= [[DSDataManager dataManager] getSongsFromPalylistName:@"Избранное"];
    [self.playlistArray addObject:playlist];
    [self.tableView reloadData];
   /*[[DSServerManager sharedManager] getSongWithPlaylist:@"1,2" OnSuccess:^(NSArray *songs) {
       self.songsArray = [NSArray arrayWithArray:songs];
       [self.tableView reloadData];
   } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
   }];*/
    
}

- (void) getSongsFromServerWithFilter:(NSString*) filter {
    
    [self.playlistArray removeAllObjects];
    [[DSServerManager sharedManager]getSongWithFilter:filter OnSuccess:^(NSArray *songs)
    {
        DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
        playlist.songsArray = [NSArray arrayWithArray:songs];
         [self.playlistArray addObject:playlist ];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
    
}

- (void) getSongsFromServerWithDays:(NSString*) days {
    
    [self.playlistArray removeAllObjects];
    [[DSServerManager sharedManager]getSongWithDays:days OnSuccess:^(NSArray *songs)
     {
         DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
         playlist.songsArray = [NSArray arrayWithArray:songs];
         [self.playlistArray addObject:playlist ];
         [self.tableView reloadData];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.playlistArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:section];
    return [playlist.songsArray count] ;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"song";
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:indexPath.section];
    DSSongTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[DSSongTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];}
    
    DSSong* song = [playlist.songsArray objectAtIndex:indexPath.row ];
    cell.titleLabel.text = song.title;
    cell.artistLabel.text = song.artist;
    
    cell.rateView.editable = false;
    cell.rateView.rating =  song.rating ;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"star_empty.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"star_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_full.png"];
    cell.rateView.maxRating = 5;

    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:song.albumLink]];
    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:song.albumLink]];
    __weak DSSongTableViewCell* weakCell = cell;
    
    cell.image.image = nil;
    
   /* [cell.image
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.image.image = image;
         [weakCell layoutSubviews];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"error = %@", [error localizedDescription]);
     }];*/
    
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedItem = indexPath.row;
    self.selectedSection = indexPath.section;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.tabBar.selectedItem.tag == 3){
        return 40;
    }else if(self.tabBar.selectedItem.tag == 5){
        return 50;
    }else{
        return 0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 && self.tabBar.selectedItem.tag == 3) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; // x,y,width,height
        headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
        NSArray *itemArray = [NSArray arrayWithObjects: @"Week", @"Two weeks", @"Month", nil];
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:itemArray];
        
        [control setFrame:CGRectMake(20.0, 5.0, 280.0, 30.0)];
        [control setSelectedSegmentIndex:self.selectedPeriod];
        [control setEnabled:YES];
        [control addTarget:self action:@selector(touchPeriod:) forControlEvents: UIControlEventValueChanged ];
        
        [headerView addSubview:control];
        [headerView bringSubviewToFront:control];
        return headerView;
        
    }
    else if (self.tabBar.selectedItem.tag == 5 ){
     
        DSHeaderTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"header"];
        headerCell.nameLabel.text = @"Custom header from cell";
        return headerCell;
        
    }
        
      return  nil;
}


- (void) touchPeriod:(UIControl *)sender {
   
    UISegmentedControl* segment = (UISegmentedControl*)sender;
    self.selectedPeriod = segment.selectedSegmentIndex;
    [self getPeriodSongs];

    
}

-(void) getPeriodSongs{
    switch(self.selectedPeriod) {
    case 0:
        [self getSongsFromServerWithDays: @"7"];
        break;
    case 1:
        [self getSongsFromServerWithDays: @"14"];
        break;
    case 2:
        [self getSongsFromServerWithDays: @"30"];
        break;
    }
    
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DSSongViewController *dc = [segue destinationViewController];
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:self.selectedSection];
    dc.song = [playlist.songsArray objectAtIndex:self.selectedItem];
    
}
#pragma mark -  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    self.navigationItem.rightBarButtonItem = nil;
    switch (item.tag)
    {
        case 1:
            [self getSongsFromServerWithFilter:@"rus"];
            break;
        case 2:
            [self getSongsFromServerWithFilter:@"eng"];
            break;
        case 3:
            [self getPeriodSongs];
            break;
        case 4:
            [self getFavoriteSongs];
            break;
        case 5:
            self.navigationItem.rightBarButtonItem = self.item;
            [self getPlaylistSongs];
            break;
            
    }
  
}
#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    } else {
        return YES;
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        UITextField *textfield = [alertView textFieldAtIndex:0];
        
        [[DSDataManager dataManager]addPlaylistwithName:textfield.text];
    }
}
#pragma mark - Methods

- (void) addPlaylist:(UIBarButtonItem *)sender {

    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"set playlist name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];

}
@end
