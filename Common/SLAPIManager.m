//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAPIManager.h"
#import <AFNetworking.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface SLAPIManager () {
    
}

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpManager;

@end

@implementation SLAPIManager
@synthesize userEmail = _userEmail, userPassword = _userPassword, userOrganization = _userOrganization, host, httpManager;

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Initialize variables
        _userEmail = nil;
        _userPassword = nil;
        _userOrganization = nil;
        host = nil;
        //httpManager = [AFHTTPRequestOperationManager manager];
        httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [httpManager.requestSerializer setValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
        
    }
    return self;
}

static SLAPIManager *sharedSingleton = nil;
+ (instancetype) sharedManager
{
    @synchronized([self class])
    {
        if (sharedSingleton == nil) {
            sharedSingleton = [[self alloc] init];
        }
        return sharedSingleton;
    }
}

- (void) setPassword:(NSString *)thePassword {
    _userPassword = [SLAPIManager sha1:thePassword];
}


+(NSString *) sha1:(NSString *)plainText
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [plainText dataUsingEncoding: NSUTF8StringEncoding]; /* or some other encoding */
    if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString* sha1 = [[NSMutableString alloc] init];
        for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; ++i)
        {
            [sha1 appendFormat: @"%02x", digest[i]];
        }
        return sha1;
    }
    else {
        return nil;
    }
}

+(NSString *)hmac:(NSString *)plainText withSecret:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    return HMAC;
}

- (void) performRequestWithMethod:(SLHTTPMethodType)theMethod withPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLRequestCallback)theCallback
{
    AFHTTPRequestOperationManager *requestManager = self.httpManager;
    //NSLog(@"requestManager: %@", requestManager);
    
    NSLog(@"baseURL: %@ , httpManager: %@", self.host, self.httpManager);
    
    if (self.host == nil)
    {
        @throw SLExceptionMissingHost;
    }
    
    //NSLog(@"baseURl: %@", self.baseURL);
    //NSLog(@"thePath: %@", thePath);
    NSURL *fullPath = [[NSURL alloc] initWithScheme:@"http" host:self.host path:thePath];
    //    NSURL *fullPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", thePath] relativeToURL:self.host];
    //NSLog(@"fullPath: %@", fullPath);
    NSString *fullPathStr = [fullPath absoluteString];
    //NSLog(@"Full path: %@", fullPathStr);
    
    // Prepare headers used for authentication
    // Expiry
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    NSString *expiry = [NSString stringWithFormat:@"%f", timeInMiliseconds];
    [requestManager setValue:expiry forKey:@"X-SL-Expires"];
    // Organization
    [requestManager setValue:self.userOrganization forKey:@"X-SL-Organization"];
    // Username
    [requestManager setValue:self.userEmail forKey:@"X-SL-Username"];
    // HMAC
    NSString *secret = _userPassword;
    NSString *msg = @"";
    NSString *hmac = [SLAPIManager hmac:msg withSecret:secret];
    [requestManager setValue:hmac forKey:@"hmac"];
    
    
    switch (theMethod) {
        case SLHTTPMethodGET:
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theParams
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            NSString *encodedJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"encodedJson: %@", encodedJson);
            //encodedJson = @"{\"filter\":{\"fields\":true,\"rels\":true}}";
            NSLog(@"GET %@", fullPathStr);
            [requestManager GET:fullPathStr parameters:@{@"p":encodedJson} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success, JSON: %@", responseObject);
                if (theCallback != nil) {
                    theCallback(nil, operation, responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                NSLog(@"Response: %@", operation.responseString);
                if (theCallback != nil) {
                    theCallback(error, operation, nil);
                }
            }];
        }
            break;
        case SLHTTPMethodPOST:
        {
            [requestManager POST:fullPathStr parameters:theParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success, JSON: %@", responseObject);
                if (theCallback != nil) {
                    theCallback(nil, operation, responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                NSLog(@"Response: %@", operation.responseString);
                if (theCallback != nil) {
                    theCallback(error, operation, nil);
                }
            }];
        }
            break;
        case SLHTTPMethodPUT:
        {
            [self performRequestWithMethod:SLHTTPMethodPUT withPath:thePath withParameters:theParams withCallback:theCallback];
        }
            break;
        case SLHTTPMethodDELETE:
        {
            [self.httpManager DELETE:[fullPath absoluteString] parameters:theParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success, JSON: %@", responseObject);
                if (theCallback != nil) {
                    theCallback(nil, operation, responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                NSLog(@"Response: %@", operation.responseString);
                if (theCallback != nil) {
                    theCallback(error, operation, nil);
                }
            }];
        }
            break;
        default:
            @throw SLExceptionImplementationNotFound;
            break;
    }
}


- (PMKPromise *) authenticateWithUserEmail:(NSString *)theEmail
                              withPassword:(NSString *)thePassword
                          withOrganization:(NSString *)theOrganization
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        //    [self setEmail:response[@"email"]];
        //    [self setToken:response[@"token"]];
        
        if (theEmail != nil && thePassword != nil && theOrganization != nil )
        {
            
            [self performRequestWithMethod:SLHTTPMethodPOST withPath:@"authenticate" withParameters:@{@"email":theEmail, @"password":thePassword} withCallback:^(NSError *error, id operation, id responseObject) {
                if (error == nil )
                {
                    // Store the token
                    NSDictionary *response = (NSDictionary *)responseObject;
                    
                    fulfiller(PMKManifold(response, operation));
                } else
                {
                    rejecter(PMKManifold(error, responseObject, operation));
                }
            }];
        } else
        {
            rejecter([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Authenticating requires user's email, password, and organization." userInfo:nil]);
        }
        
    }];
}

//- (void) authenticateWithUser:(SLUser *)theUser
//                 withCallback:(SLSuccessCallback)theCallback
//{
//    [self authenticateWithUserEmail:[theUser get:@"email"] withPassword:[theUser get:@"password"] withCallback:theCallback];
//}


@end
