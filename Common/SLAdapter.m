//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAdapter.h"
#import <AFNetworking/AFNetworking.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "SLUser.h"
#import "SLObjectIdTransform.h"

@interface SLAdapter () {

}

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpManager;

@end

@implementation SLAdapter
@synthesize userEmail = _userEmail, userPassword = _userPassword, userOrganization = _userOrganization, host, protocol, httpManager, serializer;

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
        protocol = @"http";
        serializer = [[SLSerializer alloc] init];
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
        
        NSLog(@"performRequestWithMethod: %lu, withPath: %@, withParameters: %@", theMethod, thePath, theParams);

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
        NSString *fullPathStr = [NSString stringWithFormat:@"%@://%@%@", self.protocol, self.host, absPath];
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
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theParams
                                                               options:(NSJSONWritingOptions) 0
                                                                 error:&error];
            if (error == nil && jsonData)
            {
                payload = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            } else {
                NSLog(@"JSON stringify error: %@", error);
                payload = @"";
                return rejecter(error);
            }
        } else {
            NSLog(@"theParams is empty.");
            payload = @"";
        }
        
        NSString *msg = [NSString stringWithFormat:@"%@:%@:%@:%@", methodStr, absPath, expiry, payload];
        NSLog(@"HMAC message: %@", msg);
        NSString *hmac = [SLAdapter hmac:msg withSecret:secret];
        NSLog(@"HMAC: %@", hmac);
        [requestManager.requestSerializer setValue:hmac forHTTPHeaderField:@"hmac"];
        
        switch (theMethod) {
            case SLHTTPMethodGET:
            {
                NSLog(@"GET %@", fullPathStr);
                NSDictionary *params = nil;
                if (theParams != nil)
                {
                    params = @{@"q":payload};
                }
                [requestManager GET:fullPathStr parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
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
                NSDictionary *serialized = [serializer extractSingle:[SLUser class] withPayload:response withStore:[SLStore sharedStore]];
                
                fulfiller(PMKManifold(serialized, operation));
            }).catch(rejecter);
        } else
        {
            
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Login was unsuccessful.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Authenticating requires user's email, password, and organization.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify that you have entered all of the required fields.", nil)
                                       };
            NSError *error = [NSError errorWithDomain:SLErrorDomain
                                                 code:kCFErrorHTTPBadCredentials
                                             userInfo:userInfo];
            rejecter(error);
            
        }
    }];
}

- (PMKPromise *) createRecord:(SLModel *)record withStore:(SLStore *)store;
{
    NSDictionary *options =  @{};
    NSDictionary *data = [self serialize:record withOptions:options];
    NSString *path = [NSString stringWithFormat:@"%@/create", [[record class] type]];
    return [self performRequestWithMethod:SLHTTPMethodPOST withPath:path withParameters:data];
}

- (PMKPromise *) find:(Class)modelClass withId:(SLNid)nid withStore:(SLStore *)store
{
    NSString *path = [NSString stringWithFormat:@"%@/findOne/%@", [modelClass type], nid];
    return [self performRequestWithMethod:SLHTTPMethodGET withPath:path withParameters:nil];
}

- (PMKPromise *) findAll:(Class)modelClass withStore:(SLStore *)store
{
    NSString *path = [NSString stringWithFormat:@"%@/find", [modelClass type]];
    return [self performRequestWithMethod:SLHTTPMethodGET withPath:path withParameters:nil];
}

- (PMKPromise *) findMany:(Class)modelClass withIds:(NSArray *)ids withStore:(SLStore *)store
{
    NSLog(@"ids: %@", ids);
    // Map IDs to ObjectId
    NSMutableArray *nids = [NSMutableArray array];
    for (NSString *i in ids)
    {
        NSDictionary *nid = [SLObjectIdTransform serialize:i];
        [nids addObject:nid];
    }
    
    // Create Query
    NSDictionary *query = @{
                            @"criteria": @{
                                    @"_id": @{ @"$in": nids }
                                    }
                            };
    // Send query
    NSLog(@"Query: %@", query);
    return [self findQuery:modelClass withQuery:query withStore:store];
}

- (PMKPromise *) findQuery:(Class)modelClass withQuery:(NSDictionary *)query withStore:(SLStore *)store
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        NSString *path = [NSString stringWithFormat:@"%@/find", [modelClass type]];
        [self performRequestWithMethod:SLHTTPMethodGET withPath:path withParameters:query]
        .then(fulfiller)
        .catch(rejecter);
        
    }];
}

- (PMKPromise *) deleteRecord:(SLModel *)record withStore:(SLStore *)store
{
    
    return [PMKPromise promiseWithValue:nil];
}

- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *)options
{
    return [serializer serialize:record withOptions:options];
}


@end
