//
//  SLDateTransform.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLDateTransform.h"

@implementation SLDateTransform

+ (NSDictionary *)serialize:(NSDate *)deserialized
{
    // For date conversion
    NSTimeInterval ti = [deserialized timeIntervalSince1970];
    return @{
             @"$date": [NSNumber numberWithDouble:ti]
             };
}

+ (NSDate *)deserialize:(NSDictionary *)serialized
{
    // For date conversion
    NSNumber *timestamp = serialized[@"$date"];
    if ([timestamp isEqualTo:[NSNull null]])
    {
        return nil;
    }
    NSNumber *timestampInSeconds = @([timestamp doubleValue]/1000);
    NSDate *deserialized = [NSDate dateWithTimeIntervalSince1970:[timestampInSeconds doubleValue]];
    return deserialized;
}

@end
