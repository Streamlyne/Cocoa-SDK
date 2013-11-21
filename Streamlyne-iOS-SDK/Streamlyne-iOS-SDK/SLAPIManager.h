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
    /**
     
     */
    NSString *userEmail;
    /**
     
     */
    NSString *password;
    /**
     
     */
    NSString *token;
    /**
     Address of API service.
     */
    NSString *serverAddress;
    /**
     Port number of API service.
     */
    NSUInteger serverPort;
    /**
     Path root to API.
     */
    NSString *pathRoot;
    
    @protected
    
    @public
    
}

/**
 Returns the Shared Manager instance of `SLAPI`.
 */
+ (instancetype) sharedManager;

/**
 Perform an API POST request against the server.
 @param thePath
 @param theCallback
 */
- (void) performPostRequestWithPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(id)theCallback;

/**
 Perform an API request against the server.
 @param theMethod
 @param thePath
 @param theCallback
 */
- (void) performRequestWithMethod:(NSString *)theMethod withPath:(NSString *)thePath withCallback:(id)theCallback;

/**
 Authenticate with user credentials.
 @param theEmail    The user's email.
 @param thePassword The passsword.
 */
- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword;

@end
