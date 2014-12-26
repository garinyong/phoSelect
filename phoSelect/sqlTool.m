//
//  sqlTool.m
//  phoSelect
//
//  Created by GaoYong on 14/12/25.
//
//

#import "sqlTool.h"

@implementation sqlTool

-(id) init
{
    if (self=[super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDicectory = [paths objectAtIndex:0];
        NSString *dataBasePath = [documentsDicectory stringByAppendingPathComponent:@"ppa.db"];
        
        NSFileManager*fileManager =[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:dataBasePath])
        {
            NSLog(@"exsit");
        }

        
        /*
        NSFileManager*fileManager =[NSFileManager defaultManager];
        NSString *resourcePath =[[NSBundle mainBundle] pathForResource:@"ppa" ofType:@"db"];
        NSError*error;
        [fileManager copyItemAtPath:resourcePath toPath:dataBasePath error:&error];
        
        if([fileManager fileExistsAtPath:dataBasePath])
        {
            db = [FMDatabase databaseWithPath:dataBasePath];
            if (![db open])
            {
                NSLog(@"open db failed!!!");
            }
        }
        */
    }
    
    return self;
}

-(void) saveData:(NSArray *) data
{
    return;
//    FMResultSet *rs=[db executeQuery:@"select * from phoneinfos where mobilenumber = ?"];
//    while ([rs next])
//    {
//        NSString *locationString = [NSString stringWithFormat:@"%@[%@]",[rs stringForColumn:@"mobilearea"],
//                                    [rs stringForColumn:@"mobiletype"]];
//        
//        [rs close];
//    }
//    
//    [rs close];
    
    for (NSDictionary *dict in data)
    {
        if (![dict objectForKey:@"pno"] || ![dict objectForKey:@"desp"])
        {
            continue;
        }
        
        if ([[dict objectForKey:@"pno"] containsString:@"haoma"])
        {
            continue;
        }
        
        if ([[dict objectForKey:@"desp"] containsString:@"haoma"])
        {
            continue;
        }
        
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO 'Bithphones' ('MobileNumber', 'Desp') VALUES ('%@', '%@')",
                               [dict objectForKey:@"pno"], [dict objectForKey:@"desp"]];
        BOOL res = [db executeUpdate:insertSql1];
        
        if (!res)
        {
            NSLog(@"save fail");
        }
    }
    
    NSLog(@"save success!");
}

@end
