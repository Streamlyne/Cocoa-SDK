//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAPI.h"

@interface SLAPI ()
@end

@implementation SLAPI

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Initialize variables
        userEmail = nil;
        token = nil;
    }
    return self;
}

+ (instancetype) sharedManager
{
    static SLAPI *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[SLAPI alloc] init];
        }
        return sharedSingleton;
    }
}

+ (void) authenticateWithUserEmail:(NSString *)thEmail withPassword:(NSString *)thePassword;
{
    [[SLAPI sharedManager] authenticateWithUserEmail:thEmail withPassword:thePassword];
}

- (void) authenticateWithUserEmail:(NSString *)thEmail withPassword:(NSString *)thePassword
{
    @throw SLExceptionImplementationNotFound;
}

@end
