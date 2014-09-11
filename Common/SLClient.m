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

- (instancetype) initWithHost:(NSString *)host withSSLEnabled:(BOOL)isSSL;
{
    self = [super init];
    if (self)
    {
        // 
        self.store = [SLStore sharedStore];
        [self.store.adapter setHost:host];
        if (isSSL) {
            [self.store.adapter setProtocol:@"https"];
        } else {
            [self.store.adapter setProtocol:@"http"];
        }
        self.me = nil;
    }
    return self;
}


+ (instancetype) connectWithHost:(NSString *)host withSSLEnabled:(BOOL)isSSL
{
    return [[SLClient alloc] initWithHost:host withSSLEnabled:isSSL];
}

+ (instancetype) connectWithHost:(NSString *)host
{
    return [self connectWithHost:host withSSLEnabled:false];
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
            return [self.store push:[SLUser class] withData:payload]
            .then(^(SLUser *user) {
                self.me = user;
                fulfiller(PMKManifold(self, self.me));
            });
        })
        .catch(^(NSError *error) {
            rejecter(error);
        });
    }];
}

@end
