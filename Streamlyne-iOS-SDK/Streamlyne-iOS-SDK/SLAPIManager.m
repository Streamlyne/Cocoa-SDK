//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAPIManager.h"
#import <AFNetworking/AFNetworking.h>

@interface SLAPIManager ()
@end

@implementation SLAPIManager

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Initialize variables
        userEmail = nil;
        token = nil;
        password = nil;
        serverAddress = nil;
        serverPort = 80;
        pathRoot = @"";
    }
    return self;
}

+ (instancetype) sharedManager
{
    static SLAPI *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[SLAPIManager alloc] init];
        }
        return sharedSingleton;
    }
}

- (void) performPostRequestWithPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(id)theCallback
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *fullPath = [NSString stringWithFormat:@"%@:%lu/%@/%@", serverAddress, (unsigned long)serverPort, pathRoot,  thePath];
    NSLog(@"%@", fullPath);
    [manager POST:fullPath parameters:theParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void) performRequestWithMethod:(NSString *)theMethod withPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(id)theCallback
{
    @throw SLExceptionImplementationNotFound;
}


- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword
{
    [self performPostRequestWithPath:@"authenticate" withParameters:@{@"email":theEmail, @"password":thePassword} withCallback:nil];
}

@end
