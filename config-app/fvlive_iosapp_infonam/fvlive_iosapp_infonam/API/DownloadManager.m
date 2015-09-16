//
//  DownloadManager.m
//  fvlive_iosapp_infonam
//
//  Created by Phi Nguyen on 9/16/15.
//  Copyright (c) 2015 INFONAM INC. All rights reserved.

#import "DownloadManager.h"
#import <AFNetworking.h>
#import "Utilities.h"
#define FRACTION_COMPLETED @"fractionCompleted"

@implementation DownloadManager

static DownloadManager *thisInstance;
+ (DownloadManager *) getInstance{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        thisInstance = [[DownloadManager alloc] init];
    }
    return thisInstance;
}

- (void)downloadFileWithUrl:(NSString*)strUrl{
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:[Utilities documentsPath:[response suggestedFilename]]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishedDownloadFileWith:)]) {
            [self.delegate didFinishedDownloadFileWith:filePath];
        }
        [progress removeObserver:self forKeyPath:FRACTION_COMPLETED context:NULL];
        
    }];
    [downloadTask resume];
    [progress addObserver:self
               forKeyPath:FRACTION_COMPLETED
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:FRACTION_COMPLETED]) {
        NSProgress *progress = (NSProgress *)object;
        int percentCompledted = (int)(progress.fractionCompleted * 100);
        NSLog(@"Progress… %d", percentCompledted);
        if (self.delegate && [self.delegate respondsToSelector:@selector(completePercent:)]) {
            [self.delegate completePercent:percentCompledted];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
