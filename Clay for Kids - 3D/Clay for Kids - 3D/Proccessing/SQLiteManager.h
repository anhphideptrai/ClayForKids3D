//
//  SQLiteManager.h
//  Bricks Animated 3D
//
//  Created by Phi Nguyen on 5/29/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClayStep.h"

@interface SQLiteManager : NSObject
+ (SQLiteManager*)getInstance;
- (NSMutableArray*)getAllClayGroup;
- (NSMutableArray*)getClayStepsWithIDClay:(NSString*)iDLego;
- (BOOL)didDownloadedClay:(NSString*)iDClay;
@end
