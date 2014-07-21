//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAdapter.h"
#import <AFNetworking.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "SLUser.h"

@interface SLAdapter () {
    
}

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpManager;

@end

@implementation SLAdapter
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
        // Handle Response
        httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
        httpManager.responseSerializer.acceptableContentTypes = nil;
    }
    return self;
}

static SLAdapter *sharedSingleton = nil;
+ (instancetype) sharedAdapter
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
    _userPassword = [SLAdapter sha1:thePassword];
}

+(NSString *) sha1:(NSString *)plainText
{
    if (plainText == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Argument `plainText` cannot be nil." userInfo:nil];
    }
    
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

+(NSString *)hmac:(NSString *)plainText withSecret:(NSString *)secret
{
    if (plainText == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Argument `plainText` cannot be nil." userInfo:nil];
    }
    if (secret == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Argument `secret` cannot be nil." userInfo:nil];
    }
    
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
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

- (PMKPromise *) performRequestWithMethod:(SLHTTPMethodType)theMethod
                                 withPath:(NSString *)thePath
                           withParameters:(NSDictionary *)theParams
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        AFHTTPRequestOperationManager *requestManager = self.httpManager;
        //NSLog(@"requestManager: %@", requestManager);
        
        NSLog(@"baseURL: %@ , httpManager: %@", self.host, self.httpManager);
        
        if (self.host == nil)
        {
            @throw SLExceptionMissingHost;
        }
        
        //NSLog(@"baseURl: %@", self.baseURL);
        NSLog(@"thePath: %@", thePath);
        NSString *absPath = [NSString stringWithFormat:@"/%@/%@", @"api/v1", thePath];
        NSLog(@"absPath: %@", absPath);
//        NSURL *fullPathURL = [[NSURL alloc] initWithScheme:@"http" host:self.host path:absPath];
//        NSURL *fullPath = [NSURL URLWithString:[NSString stringWithFormat:@"%@", thePath] relativeToURL:self.host];
//        NSLog(@"fullPath: %@", fullPathURL);
//        NSString *fullPathStr = [fullPathURL absoluteString];
        NSString *fullPathStr = [NSString stringWithFormat:@"%@://%@%@", @"http", self.host, absPath];
        NSLog(@"Full path: %@", fullPathStr);
        
        // Prepare headers used for authentication
        // Expiry
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        NSInteger expiryDuration = 60; // in seconds
        NSString *expiry = [NSString stringWithFormat:@"%ld", (long) timeInMiliseconds + expiryDuration];
        [requestManager.requestSerializer setValue:expiry forHTTPHeaderField:@"X-SL-Expires"];
        // Organization
        [requestManager.requestSerializer setValue:self.userOrganization forHTTPHeaderField:@"X-SL-Organization"];
        // Username
        [requestManager.requestSerializer setValue:self.userEmail forHTTPHeaderField:@"X-SL-Username"];
        // HMAC
        NSString *secret = _userPassword;
        NSLog(@"Secret: %@", secret);
        // Method
        NSString *methodStr;
        switch (theMethod) {
            case SLHTTPMethodGET: {
                methodStr = @"GET";
                break;
            }
            case SLHTTPMethodPOST: {
                methodStr = @"POST";
                break;
            }
            case SLHTTPMethodPUT: {
                methodStr = @"PUT";
                break;
            }
            case SLHTTPMethodDELETE: {
                methodStr = @"DELETE";
                break;
            }
            default:
            {
                @throw SLExceptionImplementationNotFound;
                break;
            }
        }
        // Payload
        NSString *payload;
        if (theParams != nil) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theParams
                                                               options:(NSJSONWritingOptions) 0
                                                                 error:&error];
            if (!error && jsonData)
            {
                payload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            } else {
                payload = @"";
            }
        } else {
            payload = @"";
        }
        
        NSString *msg = [NSString stringWithFormat:@"%@:%@:%@:%@", methodStr, absPath, expiry, payload];
        NSLog(@"HMAC message: %@", msg);
        NSString *hmac = [SLAdapter hmac:msg withSecret:secret];
        [requestManager.requestSerializer setValue:hmac forHTTPHeaderField:@"hmac"];
        
        switch (theMethod) {
            case SLHTTPMethodGET:
            {
                NSLog(@"GET %@", fullPathStr);
                NSString *urlWithParams = [NSString stringWithFormat:@"%@?%@", fullPathStr, payload];
                NSLog(@"urlWithParams %@", urlWithParams);
                [requestManager GET:fullPathStr parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                    NSLog(@"Success, JSON: %@", responseObject);
                    fulfiller(PMKManifold(responseObject, operation));
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    NSLog(@"Response: %@", operation.responseString);
                    rejecter(error);
                }];
            }
                break;
            case SLHTTPMethodPOST:
            {
                [requestManager POST:fullPathStr parameters:theParams success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                    NSLog(@"Request: %@", operation.request);
                    NSLog(@"Success, JSON: %@", responseObject);
                    fulfiller(PMKManifold(responseObject, operation));
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Request: %@", operation.request);
                    NSLog(@"Error: %@", error);
                    NSLog(@"Response: %@", operation.responseString);
                    rejecter(error);
                }];
            }
                break;
            case SLHTTPMethodPUT:
            {
                [self performRequestWithMethod:SLHTTPMethodPUT withPath:thePath withParameters:theParams].then(fulfiller).catch(rejecter);
            }
                break;
            case SLHTTPMethodDELETE:
            {
                [self.httpManager DELETE:fullPathStr parameters:theParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Success, JSON: %@", responseObject);
                    fulfiller(PMKManifold(responseObject, operation));
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    NSLog(@"Response: %@", operation.responseString);
                    rejecter(error);
                }];
            }
                break;
            default:
                @throw SLExceptionImplementationNotFound;
                break;
        }
    }];
}


- (PMKPromise *) authenticateWithUserEmail:(NSString *)theEmail
                              withPassword:(NSString *)thePassword
                          withOrganization:(NSString *)theOrganization
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        //
        [self setEmail:theEmail];
        [self setPassword:thePassword];
        [self setOrganization:theOrganization];
        
        //
        if (theEmail != nil && thePassword != nil && theOrganization != nil )
        {
            [self performRequestWithMethod:SLHTTPMethodGET
                                  withPath:@"me"
                            withParameters:nil]
            .then(^(id responseObject, id operation) {
                
                // Store the token
                NSDictionary *response = (NSDictionary *)responseObject;
                
                //
                SLSerializer *serializer = [[SLSerializer alloc] init];
                NSDictionary *serialized = [serializer extractSingle:[SLUser class] withPayload:response withStore:[SLStore sharedStore]];
                
                fulfiller(PMKManifold(serialized, operation));
            }).catch(rejecter);
        } else
        {
            rejecter([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Authenticating requires user's email, password, and organization." userInfo:nil]);
        }
    }];
}


- (PMKPromise *) findAll:(Class)modelClass withStore:(SLStore *)store
{
    NSString *path = [NSString stringWithFormat:@"%@/", [modelClass type]];
    return [self performRequestWithMethod:SLHTTPMethodGET withPath:path withParameters:nil];
}

//- (NSString *) buildURL:(Class)modelClass
//{
//    
//}


@end
