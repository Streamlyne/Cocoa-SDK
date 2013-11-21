//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"

@interface SLAPIManager : SLObject {
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
 @param theEmail    The user's email.
 @param thePassword The passsword.
 
 */
- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword;

@end
