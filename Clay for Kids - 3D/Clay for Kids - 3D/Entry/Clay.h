//
//  Clay.h
//  Clay for Kids - 3D
//
//  Created by Phi Nguyen on 7/24/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClayGroup.h"

@interface Clay : ClayGroup
@property (nonatomic, strong) NSString *iDClay;
@property (nonatomic) NSUInteger numberStep;
@property (nonatomic) NSUInteger rate;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic, strong) NSMutableArray *steps;
@end
