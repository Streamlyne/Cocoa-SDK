//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <PromiseKit.h>
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
#define SLExceptionMissingHost [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must specify Streamlyne API Server Host." userInfo:nil]


@interface SLAPIManager : SLObject {
    
}

@property (strong, nonatomic, setter=setEmail:) NSString *userEmail;
@property (strong, nonatomic, setter=setPassword:) NSString *userPassword;
@property (strong, nonatomic, setter=setOrganization:) NSString *userOrganization;


/**
 
 */
+(NSString *) sha1:(NSString *)plainText;

/**
 
 */
+(NSString *)hmac:(NSString *)plainText withSecret:(NSString *)key;


/**
 Host for creating URL.
 See https://developer.apple.com/library/Mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html#jumpTo_31 for more details.
 */
@property (strong, nonatomic) NSString *host;

/**
 Returns the Shared Manager instance of `SLAPIManager`.
 */
+ (instancetype) sharedManager;

/**
 Set the Email.
 */
- (void) setEmail:(NSString *)theEmail;

/**
 Set the password. Automatically saves as SHA1.
 */
- (void) setPassword:(NSString *)thePassword;

/**
 Set the Organization.
 */
- (void) setOrganization:(NSString *)theOrganization;

/**
 Perform an API request against the server.
 @param theMethod
 @param thePath
 */
- (PMKPromise *) performRequestWithMethod:(SLHTTPMethodType)theMethod
                                 withPath:(NSString *)thePath
                           withParameters:(NSDictionary *)theParams;

/**
 Authenticate with user credentials.
 @param theEmail    The user's email.
 @param thePassword The user's passsword.
 @param theOrganization The user's organization.
 */
- (PMKPromise *) authenticateWithUserEmail:(NSString *)theEmail
                      withPassword:(NSString *)thePassword
                  withOrganization:(NSString *)theOrganization;


@end
