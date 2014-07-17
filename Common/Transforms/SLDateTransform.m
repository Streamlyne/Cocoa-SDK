//
//  SLDateTransform.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLDateTransform.h"

@implementation SLDateTransform

- (NSDictionary *)serialize:(NSDate *)deserialized
{
    // For date conversion
    NSDateFormatter *iso8601Formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [iso8601Formatter setLocale:enUSPOSIXLocale];
    [iso8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return @{
             @"$date":
                 [iso8601Formatter stringFromDate:deserialized]
             };
}

- (NSDate *)deserialize:(NSDictionary *)serialized
{
    NSString *str = serialized[@"$date"];
    // For date conversion
    NSDateFormatter *iso8601Formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [iso8601Formatter setLocale:enUSPOSIXLocale];
    [iso8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [iso8601Formatter dateFromString: str];
}

@end
