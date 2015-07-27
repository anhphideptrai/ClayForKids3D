//
//  AppDelegate.h
//  Clay for Kids - 3D
//
//  Created by Phi Nguyen on 7/24/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
#import "ConfigApp.h"
#import "Constants.h"
#import "ConfigManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *moreApps;
@property (strong, nonatomic) ConfigApp *config;
@property (strong, nonatomic) DownloadManager *downloadManager;

@end

