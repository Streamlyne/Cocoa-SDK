//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLUser.h"

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
    
}

@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSURL *baseURL;

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
 Perform an API request against the server.
 @param theMethod
 @param thePath
 @param theCallback
 */
- (void) performRequestWithMethod:(SLHTTPMethodType)theMethod
                         withPath:(NSString *)thePath
                   withParameters:(NSDictionary *)theParams
                     withCallback:(SLRequestCallback)theCallback;

/**
 Authenticate with user credentials.
 @param theEmail    The user's email.
 @param thePassword The passsword.
 */
- (void) authenticateWithUserEmail:(NSString *)theEmail
                      withPassword:(NSString *)thePassword
                      withCallback:(SLSuccessCallback)theCallback;

/**
 Authenticate with user credentials.
 @param theEmail    The user's email.
 @param thePassword The passsword.
 */
- (void) authenticateWithUser:(SLUser *)theUser
                 withCallback:(SLSuccessCallback)theCallback;


@end
