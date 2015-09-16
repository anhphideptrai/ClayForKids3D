//
//  WebService.m
//  fvlive_iosapp_infonam
//
//  Created by Phi Nguyen on 9/16/15.
//  Copyright (c) 2015 INFONAM INC. All rights reserved.

#import "WebService.h"
#define _kStatus_       @"status"
#define _kVideo_url_    @"video_url"
#define _kDivide_num_x_ @"divide_num_x"
#define _kDivide_num_y_ @"divide_num_y"

@interface WebService ()

@property AFHTTPRequestOperationManager *manager;
@end
@implementation WebService
static WebService *thisInstance;
+ (WebService *) getInstance{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        thisInstance = [[WebService alloc] init];
        // Init your data here
        thisInstance.manager = [AFHTTPRequestOperationManager manager];
        thisInstance.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return thisInstance;
}
- (AFHTTPRequestOperation *)getAPIFrom:(NSString *)urlAPI
                           andFinished:(void (^)(VideoEntry *videoEntry, BOOL success))finished {
    return [self.manager GET:urlAPI
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject){
                         if (finished) {
                             if (responseObject) {
                                 NSDictionary *dict = [NSDictionary dictionaryWithDictionary:responseObject];
                                 VideoEntry *videoEntry = [VideoEntry new];
                                 [videoEntry setStatus:[dict valueForKey:_kStatus_]];
                                 [videoEntry setVideo_url:[dict valueForKey:_kVideo_url_]];
                                 [videoEntry setDivide_num_x:[dict valueForKey:_kDivide_num_x_]];
                                 [videoEntry setDivide_num_y:[dict valueForKey:_kDivide_num_y_]];
                                 finished(videoEntry, YES);
                             }else{
                                 finished(nil, NO);
                             }
                         }
                    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                        if (finished) {
                            finished(nil, NO);
                        }
            }];
}
@end
