//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"

/**
 
 */
typedef NS_ENUM(NSUInteger, SLHTTPMethodType)
{
    SLHTTPMethodGET,
    SLHTTPMethodPOST,
    SLHTTPMethodPUT,
    SLHTTPMethodDELETE
};

/**
 
 */
#define SLExceptionMissingBaseUrl [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must specify base URL." userInfo:nil]


@interface SLAPIManager : SLObject {
    @private
    /**
     
     */
    NSString *userEmail;
    /**
     
     */
    NSString *userToken;
    /**
     
     */
    NSURL *baseURL;
    
    @protected
    
    @public
    
}

/**
 Returns the Shared Manager instance of `SLAPIManager`.
 */
+ (instancetype) sharedManager;

/**
 
 */
- (void) setBaseURL:(NSURL *)theBaseURL;

/**
 
 */
- (void) setEmail:(NSString *)theEmail;

/**
 
 */
- (void) setToken:(NSString *)theToken;

/**
 Perform an API POST request against the server.
 @param thePath
 @param theCallback
 */
- (void) performPostRequestWithPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLSuccessCallback)theCallback;

/**
 Perform an API request against the server.
 @param theMethod
 @param thePath
 @param theCallback
 */
- (void) performRequestWithMethod:(SLHTTPMethodType)theMethod withPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLSuccessCallback)theCallback;

/**
 Authenticate with user credentials.
 @param theEmail    The user's email.
 @param thePassword The passsword.
 */
- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword;

@end
