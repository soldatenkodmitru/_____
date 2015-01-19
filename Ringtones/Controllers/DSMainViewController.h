//
//  DSMainViewController.h
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DSMainViewController : UIViewController <UITableViewDataSource , UITableViewDelegate, UITabBarDelegate, UIAlertViewDelegate, UITextFieldDelegate,UISearchBarDelegate, MBProgressHUDDelegate>


@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@end
