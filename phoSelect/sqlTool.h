//
//  sqlTool.h
//  phoSelect
//
//  Created by GaoYong on 14/12/25.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface sqlTool : NSObject
{
    FMDatabase *db;
}

-(void) saveData:(NSArray *) data;

@end
