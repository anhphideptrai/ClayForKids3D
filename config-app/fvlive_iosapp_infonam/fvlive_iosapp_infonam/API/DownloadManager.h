//
//  DownloadManager.h
//  fvlive_iosapp_infonam
//
//  Created by Phi Nguyen on 9/16/15.
//  Copyright (c) 2015 INFONAM INC. All rights reserved.

#import <Foundation/Foundation.h>
@protocol DownloadManagerDelegate <NSObject>
- (void)didFinishedDownloadFileWith:(NSURL*)filePath;
@optional
- (void)completePercent:(NSInteger)percent;
@end
@interface DownloadManager : NSObject
+ (DownloadManager *) getInstance;
@property (nonatomic, assign) id<DownloadManagerDelegate> delegate;
- (void)downloadFileWithUrl:(NSString*)url;
@end
