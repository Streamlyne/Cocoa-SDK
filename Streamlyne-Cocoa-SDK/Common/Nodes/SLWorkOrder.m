//
//  SLWorkOrder.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/22/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLWorkOrder.h"

@implementation SLWorkOrder
- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *name = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *description = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *status = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *notes_completion = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *date_due = [[SLValue alloc]initWithType:[NSDate class]];
        SLValue *date_completed = [[SLValue alloc]initWithType:[NSDate class]];

        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        [tempData setValue:name forKey:@"name"];
        [tempData setValue:description forKey:@"description"];
        [tempData setValue:status forKey:@"status"];
        [tempData setValue:notes_completion forKey:@"notes_completion"];
        //[tempData setValue:date_due forKey:@"date_due"];
        //[tempData setValue:date_completed forKey:@"date_completed"];
        
        self.data = tempData;
    }
    return self;
}

+(NSString *) type
{
    return @"workOrder";
}
@end
