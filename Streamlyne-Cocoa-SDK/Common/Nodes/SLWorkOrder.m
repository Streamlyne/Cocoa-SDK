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

+(NSString *) type
{
    return @"workOrder";
}

+ (NSString *) keyForKey:(NSString *)key {
    if ([key isEqualToString: @"notes_completion"]) {
        return @"notesCompletion";
    } else if ([key isEqualToString:@"date_due"]) {
        return @"dateDue";
    } else if ([key isEqualToString:@"date_completed"]) {
        return @"dateDue";
    } else if ([key isEqualToString:@"description"]) {
        return @"desc";
    } else if ([key isEqualToString:@"cost_center"]) {
        return @"costCenter";
    } else {
        return [[[self superclass] class] keyForKey:key];
    }
}

@end
