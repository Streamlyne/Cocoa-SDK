//
//  SLClient.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLStore.h"
#import "SLUser.h"
#import <Promise.h>

@interface SLClient : SLObject

@property (nonatomic, strong) SLStore *store;
@property (nonatomic, strong) SLUser *me;

/**
 
 @public
 */
+ (instancetype) connectWithHost:(NSString *)host;
 
 /**
  @private
  */
- (instancetype) initWithHost:(NSString *)host;

/**
 Authenticate with user credentials.
 @public
 @param theEmail    The user's email.
 @param thePassword The user's passsword.
 @param theOrganization The user's organization.
 */
- (PMKPromise *) authenticateWithUserEmail:(NSString *)theEmail
                              withPassword:(NSString *)thePassword
                          withOrganization:(NSString *)theOrganization;


@end
