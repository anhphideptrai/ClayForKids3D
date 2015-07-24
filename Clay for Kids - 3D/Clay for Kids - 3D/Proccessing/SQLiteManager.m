//
//  SQLiteManager.m
//  Bricks Animated 3D
//
//  Created by Phi Nguyen on 5/29/15.
//  Copyright (c) 2015 Thien Nguyen. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>

@interface SQLiteManager()

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;

@end

@implementation SQLiteManager
static SQLiteManager *thisInstance;


+ (SQLiteManager *)getInstance {
    return thisInstance;
}
+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        thisInstance = [[SQLiteManager alloc] init];
    }
}
- (SQLiteManager *)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}
- (void)copyDatabase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    _databasePath = [documentsDirectory stringByAppendingPathComponent:@"Clay_Everything.sqlite"];
    
    if ([fileManager fileExistsAtPath:_databasePath] == NO) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"Clay_Everything.sqlite" ofType:@""];
        [fileManager copyItemAtPath:resourcePath toPath:_databasePath error:&error];
    }
    if (_contactDB) {
        sqlite3_close(_contactDB);
    }
}
- (NSMutableArray*)getArrClayWithiDGroup:(NSString*)iDGroup orWithArrIDClay:(NSArray*)iDClays{
    [self copyDatabase];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
     Clay *clay;
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = @"";
        if (iDClays && iDClays.count > 0) {
            NSString *tmp = @"";
            for (NSString *iDItem in iDClays) {
                tmp = [tmp stringByAppendingFormat:([tmp isEqualToString:@""]?@"'%@'":@",'%@'"), iDItem];
            }
            querySQL = [NSString stringWithFormat:@"select * from clay where iDClay in (%@) group by iDClay", tmp];
        }else{
            querySQL = [NSString stringWithFormat:@"select * from clay where iDGroup = '%@' group by iDClay", iDGroup];
        }
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                clay = [[Clay alloc] init];
                clay.iDGroup = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                clay.iDClay = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                clay.name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                clay.numberStep = sqlite3_column_int(statement, 3);
                clay.rate = sqlite3_column_int(statement, 4);
                clay.isDownloaded = sqlite3_column_int(statement, 5);
                [resultArray addObject:clay];
            }
            sqlite3_finalize(statement);
        }
        
        
        sqlite3_close(_contactDB);
    }
    return resultArray;
    
}
- (NSMutableArray*)getAllClayGroup{
    [self copyDatabase];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    ClayGroup *group;
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select * from groupclay group by iDGroup"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                group = [[ClayGroup alloc] init];
                group.iDGroup = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                group.name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                group.clays = [self getArrClayWithiDGroup:group.iDGroup orWithArrIDClay:group.iDClays];
                [resultArray addObject:group];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
    return resultArray;

}
- (NSMutableArray*)getClayStepsWithIDClay:(NSString*)iDClay{
    [self copyDatabase];
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    ClayStep *step;
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select * from stepclay where iDClay = '%@' group by iDStep", iDClay];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                step = [[ClayStep alloc] init];
                step.iDClay = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
                step.iDStep = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 1)];
                step.urlImage = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
                step.size = sqlite3_column_int(statement, 3);
                [resultArray addObject:step];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }
    return resultArray;
}
- (BOOL)didDownloadedClay:(NSString*)iDClay{
    [self copyDatabase];
    BOOL result = NO;
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"UPDATE clay SET isDownload = \"1\" WHERE iDClay = '%@'",iDClay];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        result = (sqlite3_step(statement) == SQLITE_DONE);
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
    return result;
}
@end
