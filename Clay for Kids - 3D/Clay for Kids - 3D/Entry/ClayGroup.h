//
//  ClayGroup.h
//  Clay for Kids - 3D
//
//  Created by Phi Nguyen on 7/24/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClayGroup : NSObject
@property (nonatomic, strong) NSString *iDGroup;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *iDClays;
@property (nonatomic, strong) NSMutableArray *clays;
@end
