//
//  DSMainViewController.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSMainViewController.h"
#import "DSPlayerViewController.h"
#import "DSSongTableViewCell.h"
#import "DSHeaderTableViewCell.h"
#import "DSSegmentTableViewCell.h"
#import "DSRateView.h"
#import "DSServerManager.h"
#import "DSPlaylistPlayer.h"
#import "DSSong.h"
#import "UIImageView+AFNetworking.h"
#import "DSPlaylistItem.h"
#import "DSDataManager.h"


typedef enum {
    DSSongSearch,
    DSArtistSearch
}DSSortType;

@interface DSMainViewController ()

    @property (weak,nonatomic) UISearchBar *searchBar;
    @property (strong, nonatomic) UIBarButtonItem* item;
    @property (strong, nonatomic) NSArray* baseArray;
    @property (strong, nonatomic) NSArray* playlistArray;
    @property (assign, nonatomic) NSInteger selectedSection;
    @property (assign, nonatomic) NSInteger selectedItem;
    @property (assign, nonatomic) NSInteger selectedPeriod;
    @property (assign, nonatomic) NSInteger selectedSearch;
    @property (strong,nonatomic)  NSThread* thread;
    @property (weak, nonatomic) UIImage* selectedImage;

@end

@implementation DSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getSongsFromServerWithFilter:@"rus"];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.selectedPeriod = 0;
    [self setDefaultPlaylists];
    self.baseArray = [[NSMutableArray alloc] init];
    self.item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist:)];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.selectedSearch = DSSongSearch;
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchShow:)];
    
    self.navigationItem.leftBarButtonItem = item;
    
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
 
    self.baseArray = [NSArray arrayWithArray:[[DSDataManager dataManager] allPlaylists]];
    self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];
     [self.tableView reloadData];
}

- (void) getFavoriteSongs{
    

    DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
    playlist.name = @"Избранное";
    playlist.songsArray= [[DSDataManager dataManager] getSongsFromPalylistName:@"Избранное"];
    self.baseArray = [NSArray arrayWithObject:playlist];
     self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];
    [self.tableView reloadData];
   /*[[DSServerManager sharedManager] getSongWithPlaylist:@"1,2" OnSuccess:^(NSArray *songs) {
       self.songsArray = [NSArray arrayWithArray:songs];
       [self.tableView reloadData];
   } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
   }];*/
    
}

- (void) getSongsFromServerWithFilter:(NSString*) filter {
    
    [[DSServerManager sharedManager]getSongWithFilter:filter OnSuccess:^(NSArray *songs)
    {
        DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
        playlist.songsArray = [NSArray arrayWithArray:songs];
        self.baseArray =  [NSArray arrayWithObject:playlist];
     
        self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
    
}

- (void) getSongsFromServerWithDays:(NSString*) days {
    
    [[DSServerManager sharedManager]getSongWithDays:days OnSuccess:^(NSArray *songs)
     {
         DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
         playlist.songsArray = [NSArray arrayWithArray:songs];
         self.baseArray = [NSArray arrayWithObject:playlist];
            self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];;
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
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
//    return NO;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"song";
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:indexPath.section];
    DSSongTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[DSSongTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];}
    
    DSSong* song = [playlist.songsArray objectAtIndex:indexPath.row ];
    UIGestureRecognizer * gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [cell addGestureRecognizer:gesture];
    cell.titleLabel.text = song.title;
    cell.artistLabel.text =song.artist;
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"but_onward.png"]];
  

    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:song.albumLink]];
    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:song.albumLink]];
    __weak DSSongTableViewCell* weakCell = cell;
    
    //cell.image.image = nil;
    
   [cell.image
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.image.image = image;
         CALayer *imageLayer = weakCell.image.layer;
         [imageLayer setCornerRadius:27.5f];
         [imageLayer setMasksToBounds:YES];
        // [weakCell layoutSubviews];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"error = %@", [error localizedDescription]);
     }];
    
    
    return cell;
}

#pragma mark - Methods

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    self.tableView.editing = !self.tableView.editing;
}

- (void)searchShow:(UIBarButtonItem *)sender {
    
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    
    if ([self.navigationItem.titleView isKindOfClass:[UISearchBar class]]) {
        
        item = UIBarButtonSystemItemSearch;
        
        UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:@[@"Композиция",@"Исполнитель"]];
        [control addTarget:self action:@selector(searchSongsControl:) forControlEvents:UIControlEventValueChanged];
        control.selectedSegmentIndex = self.selectedSearch;
        self.navigationItem.titleView = control;
        
    } else {
        
        UISearchBar *searchBar = [[UISearchBar alloc]init];
        self.searchBar = searchBar;
        self.searchBar.delegate = self;
        self.navigationItem.titleView = self.searchBar;
        
    }
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item target:self action:@selector(searchShow:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    
}

- (NSArray *)searchPlaylist:(NSArray *)array forType:(DSSortType)type withFilter:(NSString*)filter{
   
    NSArray *tmpArray = [[NSArray alloc] initWithArray:array copyItems:YES];
    
    switch (type) {
        
        case DSSongSearch:
        {
            for (DSPlaylistPlayer* list in tmpArray) {
                NSMutableArray* searchArray = [NSMutableArray array];
                for(DSSong* song in list.songsArray) {
                    if ([filter length] == 0 || [song.title rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [searchArray addObject:song];
                    }
                }
                list.songsArray = [NSArray arrayWithArray:searchArray];
            }
            
        }
            break;
        case DSArtistSearch:
        {
            
            for (DSPlaylistPlayer* list in tmpArray) {
                NSMutableArray* searchArray = [NSMutableArray array];
                for(DSSong* song in list.songsArray) {
                    if ([filter length] == 0 || [song.artist rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [searchArray addObject:song];
                    }
                }
                list.songsArray = [NSArray arrayWithArray:searchArray];
            }
        }
            break;
        default:
            break;
    }
    
    return tmpArray;
    
}



- (void)searchSongsControl:(UISegmentedControl *)sender {
    
    self.selectedSearch = sender.selectedSegmentIndex;
    
}
- (void)searchInBackgroundWithFilter:(NSString*) filterString {
    
    if ([self.thread isExecuting]) {
        [self.thread cancel];
    }
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(searchThreadWithFilter:) object:filterString];
    self.thread.name = @"search";
    [self.thread start];
}

- (void)searchThreadWithFilter:(NSString*) filter {
    
    self.playlistArray = [self searchPlaylist:self.baseArray forType:(DSSortType)self.selectedSearch withFilter:filter ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



- (void) addPlaylist:(UIBarButtonItem *)sender {
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"set playlist name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
    
}

- (void) deletePlaylist:(UIButton *)sender {
 
    DSPlaylistPlayer* list =[self.playlistArray objectAtIndex:sender.tag];
    if([[DSDataManager dataManager] deletePlaylistWithId:list.listId ])
       [self getPlaylistSongs];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DSPlaylistPlayer* list =[self.playlistArray  objectAtIndex:indexPath.section];
        
       NSMutableArray *songsArray = [NSMutableArray arrayWithArray:list.songsArray];
        
        DSSong *deleteSong = [songsArray objectAtIndex:indexPath.row ];
        
        [songsArray removeObject:deleteSong];
        
       list.songsArray = songsArray ;
      
        [[DSDataManager dataManager] deletePlaylistItemWithId:deleteSong.songId];
         [self.tableView reloadData];
        
    }
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    DSPlaylistPlayer* sourceList =[self.playlistArray  objectAtIndex:sourceIndexPath.section];
    DSPlaylistPlayer* destList =[self.playlistArray  objectAtIndex:destinationIndexPath.section];
    NSMutableArray *sourceSongsArray = [NSMutableArray arrayWithArray:sourceList.songsArray];
    NSMutableArray *destSongsArray = [NSMutableArray arrayWithArray:destList.songsArray];
    DSSong *moveSong = [sourceSongsArray objectAtIndex:sourceIndexPath.row];
    [sourceSongsArray removeObject:moveSong];
    if (sourceIndexPath.section == destinationIndexPath.section) {
        
       
        [sourceSongsArray insertObject:moveSong atIndex:destinationIndexPath.row];
        [[DSDataManager dataManager] ordNoWithPlaylist:sourceSongsArray];
    }
    else{
      
        [[DSDataManager dataManager] deletePlaylistItemWithId:moveSong.songId];
        moveSong.songId = [[DSDataManager dataManager] addPlaylistItemForIdList:destList.listId song:moveSong ];
        [destSongsArray insertObject:moveSong atIndex:destinationIndexPath.row];
        [[DSDataManager dataManager] ordNoWithPlaylist:destSongsArray];
   
        
    }
    
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedItem = indexPath.row;
    self.selectedSection = indexPath.section;
    DSSongTableViewCell *curCell = (DSSongTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedImage = curCell.image.image;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 65;
    
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
        DSSegmentTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"segment"];
        if (!headerCell) {
            headerCell = [[DSSegmentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"segment"];}
       [headerCell.segmentPeriod setSelectedSegmentIndex:self.selectedPeriod];
        [headerCell.segmentPeriod addTarget:self action:@selector(touchPeriod:) forControlEvents: UIControlEventValueChanged ];
        return headerCell;
        
    }
    else if (self.tabBar.selectedItem.tag == 5 ){
     
        DSHeaderTableViewCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"header"];
        if (!headerCell) {
            headerCell = [[DSHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"header"];}
        headerCell.deleteButton.tag = section;
        [headerCell.deleteButton addTarget:self action:@selector(deletePlaylist:) forControlEvents: UIControlEventTouchUpInside];
        DSPlaylistPlayer* list =  [self.playlistArray objectAtIndex:section];
        headerCell.nameLabel.text = list.name;
        return headerCell;
        
    }
        
      return  nil;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DSPlayerViewController *dc = [segue destinationViewController];
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:self.selectedSection];
    dc.song = [playlist.songsArray objectAtIndex:self.selectedItem];
    dc.pictureSong = self.selectedImage;
    
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
        
       if ( [[DSDataManager dataManager]addPlaylistwithName:textfield.text] != nil)
           [self getPlaylistSongs];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self searchInBackgroundWithFilter:self.searchBar.text];
    
}
@end
