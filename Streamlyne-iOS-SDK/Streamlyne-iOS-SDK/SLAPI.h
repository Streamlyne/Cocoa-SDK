//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import <AFNetworking.h>

@interface SLAPI : SLObject {
    @private
    NSString *userEmail;
    NSString *password;
    NSString *token;
    
    @protected
    
    @public
    
}

/**
 Returns the Shared Manager instance of `SLAPI`.
 */
+ (instancetype) sharedManager;

/**
 Authenticate with user credentials.
 @param thePassword The passsword.
 @param theEmail    The user's email.
 */
- (void) authenticateWithUserEmail:(NSString *)thEmail withPassword:(NSString *)thePassword;

@end
