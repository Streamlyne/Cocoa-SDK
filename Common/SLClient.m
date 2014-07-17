//
//  SLClient.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLClient.h"

@implementation SLClient

@synthesize store, me;

- (instancetype) initWithHost:(NSString *)host
{
    self = [super init];
    if (self)
    {
        // 
        self.store = [SLStore sharedStore];
        [self.store.adapter setHost:host];
        self.me = [NSNull null];
    }
    return self;
}

+ (instancetype) connectWithHost:(NSString *)host
{
    return [[SLClient alloc] initWithHost:host];
}


- (PMKPromise *) authenticateWithUserEmail:(NSString *)theEmail
                              withPassword:(NSString *)thePassword
                          withOrganization:(NSString *)theOrganization
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self.store.adapter authenticateWithUserEmail:theEmail
                                           withPassword:thePassword
                                       withOrganization:theOrganization]
        .then(^(NSDictionary *payload) {
            self.me = (SLUser *)[self.store push:[SLUser class] withData:payload];
            fulfiller(PMKManifold(self, self.me));
        })
        .catch(^(NSError *error) {
            rejecter(error);
        });
    }];
}

@end
