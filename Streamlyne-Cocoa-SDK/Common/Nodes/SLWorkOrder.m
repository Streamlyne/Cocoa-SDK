//
//  SLWorkOrder.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/22/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLWorkOrder.h"

@implementation SLWorkOrder

@dynamic name, desc, notesCompletion, status, dateDue, dateCompleted, costCenter;

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
        
        // Edit Data Mapping
        NSMutableDictionary *tempDataMapping = [self.dataMapping mutableCopy];
        [tempDataMapping setObject:@{ @"class": @"NSString", @"key": @"name" } forKey:@"name"];
        [tempDataMapping setObject:@{ @"class": @"NSString", @"key": @"status" } forKey:@"status"];
        [tempDataMapping setObject:@{ @"class": @"NSString", @"key": @"notesCompletion" } forKey:@"notes_completion"];
        [tempDataMapping setObject:@{ @"class": @"NSDate", @"key": @"dateCompleted" } forKey:@"date_completed"];
        [tempDataMapping setObject:@{ @"class": @"NSDate", @"key": @"dateDue" } forKey:@"date_due"];
        [tempDataMapping setObject:@{ @"class": @"NSString", @"key": @"desc" } forKey:@"description"];
        [tempDataMapping setObject:@{ @"class": @"NSString", @"key": @"costCenter" } forKey:@"cost_center"];
        self.dataMapping = tempDataMapping;
        
    }
    return self;
}

+(NSString *) type
{
    return @"workOrder";
}
@end
