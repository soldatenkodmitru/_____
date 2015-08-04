//
//  DSMainViewController.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSMainViewController.h"
#import "DSPlayerViewController.h"
#import "DSPlaylistViewController.h"
#import "DSSongTableViewCell.h"
#import "DSAddPlaylistTableViewCell.h"
#import "DSSegmentTableViewCell.h"
#import "DSRateView.h"
#import "DSServerManager.h"
#import "DSPlaylistPlayer.h"
#import "DSSong.h"
#import "UIImageView+AFNetworking.h"
#import "DSPlaylistItem.h"
#import "DSDataManager.h"
#import "GMDCircleLoader.h"
#import "TSActionSheet.h"
#import "SARate.h"
#import "DSSoundManager.h"

typedef enum {
    DSSongSearch,
    DSArtistSearch
}DSSortType;

@interface DSMainViewController ()

    @property (strong, nonatomic) UIBarButtonItem* navBarItem;
    @property (strong, nonatomic) NSArray* baseArray;
    @property (strong, nonatomic) NSArray* playlistArray;
    @property (assign, nonatomic) NSInteger selectedSection;
    @property (assign, nonatomic) NSInteger selectedItem;
    @property (assign, nonatomic) NSInteger selectedPeriod;
    @property (assign, nonatomic) NSInteger selectedSearch;
    @property (strong,nonatomic)  NSThread* thread;
    @property (strong, nonatomic) UIImage* selectedImage;
    @property (assign, nonatomic) bool noFirstLoad;
    @property (strong, nonatomic) UIBarButtonItem* appLikeItemBar;
    @property (strong,nonatomic ) FBLikeControl* likeControl;
@end

@implementation DSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getSongsFromServerWithFilter:@"rus"];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.selectedPeriod = 0;
    [self setDefaultPlaylists];
    
   
    FBLikeControl* appLikeControl = [[FBLikeControl alloc] init];
    appLikeControl.likeControlStyle = FBLikeControlStyleButton;
    appLikeControl.objectID = @"https://www.facebook.com/pages/Top50Ringtones/431758676974661";
    self.appLikeItemBar = [[UIBarButtonItem alloc] initWithCustomView:appLikeControl];
    self.navigationItem.leftBarButtonItem = self.appLikeItemBar;

   
    self.baseArray = [[NSMutableArray alloc] init];

    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.selectedSearch = DSSongSearch;
    
    UIImage *btnImg = [UIImage imageNamed:@"button_settings.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showActionSheet:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Изменить" style:UIBarButtonItemStylePlain target:self action:@selector(editMode)];
    UIImage *blank = [UIImage imageNamed:@"ic_search.png"];
    [self.searchBar setImage:blank forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
    self.navigationItem.rightBarButtonItem = item;
    
    
  //  [SARate sharedInstance].applicationBundleID = @"com.bestapp-studio.chatdietolog";
    [SARate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [SARate sharedInstance].previewMode = NO;

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*   if (self.noFirstLoad){
        switch (self.tabBar.selectedItem.tag) {
        case 4:
           [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [GMDCircleLoader setOnView:self.view withRect:self.tableView.bounds animated:YES];
            [self getFavoriteSongs];
            break;
        case 5:
           [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
           [GMDCircleLoader setOnView:self.view withRect:self.tableView.bounds animated:YES];
            
           [self getPlaylistSongs];
            break;
       }
    } */

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.noFirstLoad){
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [GMDCircleLoader setOnView:self.view withRect:self.tableView.bounds animated:YES];
        self.noFirstLoad = YES;
    }
    
  


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
 
    [[DSDataManager dataManager] allPlaylistsOnSuccess:^(NSArray *songs, NSError *error) {
        if (error == nil) {
            self.baseArray = [NSArray arrayWithArray:songs];
            self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];
            [self.tableView reloadData];
            
        }
        else {
             NSLog(@"%@", [error localizedDescription]);
        }
        [GMDCircleLoader hideFromView:self.view animated:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
    }];
    
}

- (void) getFavoriteSongs{
    

    DSPlaylistPlayer* playlist = [[DSPlaylistPlayer alloc] init];
    playlist.name = @"Избранное";
    playlist.songsArray= [[DSDataManager dataManager] getSongsFromPalylistName:@"Избранное"];
    self.baseArray = [NSArray arrayWithObject:playlist];
     self.playlistArray = [[NSArray alloc ]initWithArray:self.baseArray copyItems:YES];
    [self.tableView reloadData];
    [GMDCircleLoader hideFromView:self.view animated:YES];
   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [GMDCircleLoader hideFromView:self.view animated:YES];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        [self errorLoading:error];
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
         [GMDCircleLoader hideFromView:self.view animated:YES];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         [self errorLoading:error];
         
     }];
    
}

- (void) errorLoading:(NSError *)err {
    [GMDCircleLoader hideFromView:self.view animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    NSString *errorMessage ;
    if ([[DSServerManager sharedManager]reachability]){
        errorMessage = @"Невозможно установить соединение с сервером, повторите попытку через несколько минут";
    }else{
        errorMessage = @"Проверьте интернет соединение";
    }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Oк"
                                              otherButtonTitles:nil];
    [alertView show];
    [self.tableView reloadData];
     NSLog(@"error = %@, ", [err localizedDescription]);

}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.playlistArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:section];
    if ( [self.playlistArray count ]   == section + 1  && self.tabBar.selectedItem.tag == 5)
        return [playlist.songsArray count]  + 1 ;
    else
        return [playlist.songsArray count] ;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:[indexPath section]];
     if(self.tabBar.selectedItem.tag == 5 &&  [playlist.songsArray count] > [indexPath row])
        return YES;
     else{
        if(self.tabBar.selectedItem.tag == 4)
            return YES;
        else
            return NO;
     }
}
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
//    return NO;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURLRequest* request ;
    static NSString* identifierSong = @"song";
    static NSString* identifierAdd = @"addPlaylist";
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:indexPath.section];
    
    
    if(self.tabBar.selectedItem.tag == 5 &&  indexPath.row+1 > [playlist.songsArray count] ){
        
        DSAddPlaylistTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierAdd];
        if (!cell) {
            cell = [[DSAddPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifierSong];}
        [cell.addButton addTarget:self action:@selector(addPlaylist:) forControlEvents: UIControlEventTouchUpInside];
        return cell;
    }
    else{
        DSSongTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierSong];
        
        if (!cell) {
            cell = [[DSSongTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifierSong];}
    
        DSSong* song = [playlist.songsArray objectAtIndex:indexPath.row ];

 
        cell.titleLabel.text = song.title;
        cell.artistLabel.text =song.artist;
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld.", indexPath.row+1];
       
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"but_onward.png"]];
  

        cell.image.image = [UIImage imageNamed:@"cover_blank.png"];
        cell.haveImage = NO;
        __weak DSSongTableViewCell* weakCell = cell;

        if (song.isLocal) {
          NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:song.saveImageLink]];
            if(data != nil) {
              cell.image.image = [UIImage imageWithData:data];
              cell.haveImage = YES;
            }
          CALayer *imageLayer = cell.image.layer;
            [imageLayer setCornerRadius:27.5f];
            [imageLayer setMasksToBounds:YES];
        }
        else
        {
          request = [NSURLRequest requestWithURL:[NSURL URLWithString:song.albumLink]];
        
        [cell.image
         setImageWithURLRequest:request
         placeholderImage:nil
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.image.image = image;
         weakCell.haveImage = YES;
         CALayer *imageLayer = weakCell.image.layer;
         [imageLayer setCornerRadius:27.5f];
         [imageLayer setMasksToBounds:YES];
        // [weakCell layoutSubviews];
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             NSLog(@"error = %@", [error localizedDescription]);
         }];
        }
        return cell;
    }
}

#pragma mark - Methods

-(void)editMode {
    
    
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing){
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(editMode)];
        self.navigationItem.leftBarButtonItem = item;
    }
    else{
        self.navigationItem.leftBarButtonItem = self.navBarItem;
    }
}




-(void) showActionSheet:(id)sender  forEvent:(UIEvent*)event
    {
        TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:@"Условие поиска"];
        
        switch (self.selectedSearch)
        {
            case DSSongSearch :
            {
                [actionSheet destructiveButtonWithTitle:@"название" block:^{
                    self.selectedSearch = DSSongSearch;
                    [self searchInBackgroundWithFilter:self.searchBar.text];
                }];
        
                [actionSheet addButtonWithTitle:@"исполнитель" block:^{
                    self.selectedSearch = DSArtistSearch;
                    [self searchInBackgroundWithFilter:self.searchBar.text];
                }];
                break;
            }
            case DSArtistSearch:
            {
                [actionSheet addButtonWithTitle:@"название" block:^{
                    self.selectedSearch = DSSongSearch;
                    [self searchInBackgroundWithFilter:self.searchBar.text];
                }];
                
                [actionSheet destructiveButtonWithTitle:@"исполнитель" block:^{
                    self.selectedSearch = DSArtistSearch;
                    [self searchInBackgroundWithFilter:self.searchBar.text];
                }];
                break;
            }
            default:
                break;
        }

        //  [actionSheet cancelButtonWithTitle:@"Cancel" block:nil];
        actionSheet.cornerRadius = 5;
        
        [actionSheet showWithTouch:event];
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



- (void) addPlaylist:(UIButton*)sender {
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Укажите название плейлиста" message:nil delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Готово",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 1;
    [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
    
}

- (void) deletePlaylist:(UIButton *)sender {
 
    
    self.selectedSection = sender.tag;
    DSPlaylistPlayer* list = [self.playlistArray objectAtIndex:sender.tag];
    NSString* title = [NSString stringWithFormat:@"Удалить плейлист ""%@"" ? ", list.name];
    
    
     UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да",nil];
     alertView.tag = 2;
    [alertView show];
    
  
}

- (void) touchPeriod:(UIControl *)sender {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [GMDCircleLoader setOnView:self.view withRect:self.tableView.bounds animated:YES];

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
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"Удалить";
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    DSPlaylistPlayer* sourceList =[self.playlistArray  objectAtIndex:sourceIndexPath.section];
    DSPlaylistPlayer* destList =[self.playlistArray  objectAtIndex:destinationIndexPath.section];
    NSMutableArray *sourceSongsArray = [NSMutableArray arrayWithArray:sourceList.songsArray];
    NSMutableArray *destSongsArray = [NSMutableArray arrayWithArray:destList.songsArray];
    DSSong *moveSong = [sourceSongsArray objectAtIndex:sourceIndexPath.row];
    [sourceSongsArray removeObject:moveSong];
    if (sourceIndexPath.section == destinationIndexPath.section) {
        
        
       if (destinationIndexPath.row > [sourceSongsArray count] )
         [sourceSongsArray insertObject:moveSong atIndex:destinationIndexPath.row-1];
       else
        [sourceSongsArray insertObject:moveSong atIndex:destinationIndexPath.row];
        
        if( [[DSDataManager dataManager] ordNoWithPlaylist:sourceSongsArray]){
           [self getPlaylistSongs];
           [self.tableView reloadData];
        }
    }
    else{
      
        [[DSDataManager dataManager] deletePlaylistItemWithId:moveSong.songId];
        moveSong.songId = [[DSDataManager dataManager] addPlaylistItemForIdList:destList.listId song:moveSong ];
          if (destinationIndexPath.row > [destSongsArray count] )
                [destSongsArray insertObject:moveSong atIndex:destinationIndexPath.row-1];
          else
              [destSongsArray insertObject:moveSong atIndex:destinationIndexPath.row];
        
        if([[DSDataManager dataManager] ordNoWithPlaylist:destSongsArray]){
            [self getPlaylistSongs];
            [self.tableView reloadData];
        }
    }
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if(self.tabBar.selectedItem.tag == 5 || self.tabBar.selectedItem.tag == 4 ) {
        DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:self.selectedSection];
        if(!(self.tabBar.selectedItem.tag == 5 &&  indexPath.row+1 > [playlist.songsArray count] )){
            DSPlaylistViewController *myVController = (DSPlaylistViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
            [DSSoundManager sharedManager].playlist = playlist;
            [DSSoundManager sharedManager].activeIndex = self.selectedItem;
            myVController.song = [playlist.songsArray objectAtIndex:self.selectedItem];
            [DSSoundManager sharedManager].song = myVController.song;
            [DSSoundManager sharedManager].isPlaying = NO;
            myVController.pictureSong = self.selectedImage;
            [self.navigationController pushViewController:myVController animated:YES];
       }
    }
    else{
        
        DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:self.selectedSection];
        DSPlayerViewController *myVController = (DSPlayerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"Player"];
        myVController.title = [NSString stringWithFormat:@"%d из %d",self.selectedItem+1, [playlist.songsArray count]];
        myVController.song = [playlist.songsArray objectAtIndex:self.selectedItem];
        myVController.pictureSong = self.selectedImage;
        [self.navigationController pushViewController:myVController animated:YES];

    }
    [[DSSoundManager sharedManager] resetStreamer];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:indexPath.section];

    self.selectedItem = indexPath.row;
    self.selectedSection = indexPath.section;
    if(self.tabBar.selectedItem.tag == 5 &&  indexPath.row+1 > [playlist.songsArray count] ){
        [ self addPlaylist:nil];
    }
    else
    {
       
        DSSongTableViewCell *curCell = (DSSongTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (curCell.haveImage == YES)
            self.selectedImage = curCell.image.image;
        else
            self.selectedImage = [UIImage imageNamed:@"default_fon.png"];
    }
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DSPlaylistPlayer* playlist = [self.playlistArray objectAtIndex:indexPath.section];
    if(self.tabBar.selectedItem.tag == 5 &&  indexPath.row+1 > [playlist.songsArray count] )
        return 45;
    else
        return 65;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.tabBar.selectedItem.tag == 3){
        return 40;
    }else if(self.tabBar.selectedItem.tag == 5){
        return 30;
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
     
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,30)];
       
        UILabel* headerLabel = [[UILabel alloc] init];
        headerLabel.frame = CGRectMake(20, 5, tableView.frame.size.width - 200, 20);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor   blackColor];
        headerLabel.font = [UIFont fontWithName:@"Helvetica-5-Normal" size:18];
        DSPlaylistPlayer* list =  [self.playlistArray objectAtIndex:section];
        headerLabel.text = list.name;;
        headerLabel.textAlignment = NSTextAlignmentLeft;
       
        
       
            UILabel* headerCount = [[UILabel alloc] init];
            headerCount.frame = CGRectMake(tableView.frame.size.width - 90, 5, 50, 20);
            headerCount.backgroundColor = [UIColor clearColor];
            headerCount.textColor = [UIColor  grayColor];
            headerCount.font = [UIFont fontWithName:@"Helvetica-5-Normal" size:18];
            headerCount.text = [NSString stringWithFormat:@"(%d)",[list.songsArray count] ];
            headerCount.textAlignment = NSTextAlignmentCenter;
            [headerView addSubview:headerCount];
        
        
        
        if(section > 1){
        
            UIButton* headerButton = [[UIButton alloc] init];
            UIImage *btnImg = [UIImage imageNamed:@"cancel_blue.png"];
            headerButton.frame = CGRectMake(tableView.frame.size.width - 40, 5, btnImg.size.width, btnImg.size.height);
            [headerButton setImage:btnImg forState:UIControlStateNormal];
            headerButton.tag = section;
            [headerButton addTarget:self action:@selector(deletePlaylist:) forControlEvents: UIControlEventTouchUpInside];
            [headerView addSubview:headerButton];
        }
        
        UIImage *separatorImg = [UIImage imageNamed:@"separator.png"];
        UIImageView* separator = [[UIImageView alloc] initWithImage:separatorImg];
        
        separator.frame = CGRectMake(33, 30, separatorImg.size.width, separatorImg.size.height);

        [headerView addSubview:separator];
       
    
        [headerView addSubview:headerLabel];
        

        return headerView;
        
    }
        
      return  nil;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    
}
#pragma mark -  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {

    self.navigationItem.leftBarButtonItem = self.appLikeItemBar;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [GMDCircleLoader setOnView:self.view withRect:self.tableView.bounds animated:YES];
    switch (item.tag)
    {
        case 1:
            self.navigationItem.title = @"Топ Русский";
            [self getSongsFromServerWithFilter:@"rus"];
            break;
        case 2:
            self.navigationItem.title = @"Топ Английский";
            [self getSongsFromServerWithFilter:@"eng"];
            break;
        case 3:
            self.navigationItem.title = @"Новые";
            [self getPeriodSongs];
            break;
        case 4:
            self.navigationItem.title = @"Избранное";
            [self getFavoriteSongs];
            break;
        case 5:
            self.navigationItem.leftBarButtonItem  = self.navBarItem;
            self.navigationItem.title = @"Плейлисты";
            [self getPlaylistSongs];
            break;
            
    }
  
}
#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЭЮЯabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    } else {
        return YES;
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == 1) {
                UITextField *textfield = [alertView textFieldAtIndex:0];
                if( ![textfield.text isEqualToString:@""] && ![textfield.text isEqualToString:@"Загрузки"] && ![textfield.text isEqualToString:@"Рингтоны"] && ![textfield.text isEqualToString:@"Избранное"]){
                    if ( [[DSDataManager dataManager]addPlaylistwithName:textfield.text] != nil)
                        [self getPlaylistSongs];
                }
            }
            break;
            
        case 2:
          if (buttonIndex == 1) {
              DSPlaylistPlayer* list =[self.playlistArray objectAtIndex:self.selectedSection];
              if([[DSDataManager dataManager] deletePlaylistWithId:list.listId ])
                [self getPlaylistSongs];
            
            }
            break;
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
