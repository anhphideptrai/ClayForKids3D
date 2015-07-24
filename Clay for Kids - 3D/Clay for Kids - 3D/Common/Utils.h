//
//  Utils.h
//  Pokedex Characters
//
//  Created by Phi Nguyen on 10/11/14.
//  Copyright (c) 2014 Duc Thien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Utils : NSObject
+ (NSString *)documentsPathForFileName:(NSString *)name;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+ (void)showAlertWithError:(NSError*)err;
+ (NSURL*)getURLBundleForFileName:(NSString*)fileName;
+ (NSURL*)getURLImageForIDLego:(NSString*)iDLego andFileName:(NSString*)fileName;
+ (NSURL*)getURLImageForIDSimpleLego:(NSString*)iDLego andFileName:(NSString*)fileName;
//+ (NSString *) admobDeviceID;
@end
