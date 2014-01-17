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


+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"notesCompletion" forKey:@"notes_completion"];
    [attrMap setValue:@"dateDue" forKey:@"date_due"];
    [attrMap setValue:@"dateCompleted" forKey:@"date_completed"];
    [attrMap setValue:@"desc" forKey:@"description"];
    [attrMap setValue:@"costCenter" forKey:@"cost_center"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}

@end
