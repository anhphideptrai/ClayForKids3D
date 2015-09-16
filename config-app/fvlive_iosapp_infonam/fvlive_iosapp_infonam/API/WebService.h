//
//  WebService.h
//  fvlive_iosapp_infonam
//
//  Created by Phi Nguyen on 9/16/15.
//  Copyright (c) 2015 INFONAM INC. All rights reserved.

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "VideoEntry.h"
@interface WebService : NSObject
+ (WebService *) getInstance;

- (AFHTTPRequestOperation *)getAPIFrom:(NSString *)urlAPI
                           andFinished:(void (^)(VideoEntry *videoEntry, BOOL success))finished;
@end
