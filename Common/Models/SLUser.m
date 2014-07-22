//
//  SLUser.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLUser.h"
#import "SLAdapter.h"

@implementation SLUser


@dynamic email;
@dynamic jobTitle;
@dynamic firstName;
@dynamic lastName;
@dynamic password;

+ (NSString *) type
{
    return @"user";
}

+ (NSString *) keyForAttribute:(NSString *)attribute
{
    attribute = [super keyForAttribute:attribute];
    
    if ([attribute isEqualToString:@"jobTitle"])
    {
        return @"job_title";
    } else if ([attribute isEqualToString:@"firstName"])
    {
        return @"first_name";
    } else if ([attribute isEqualToString:@"lastName"])
    {
        return @"last_name";
    }
    
    return attribute;
}

@end
