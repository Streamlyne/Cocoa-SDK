//
//  SLAPI.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAPIManager.h"
#import <AFNetworking.h>

@interface SLAPIManager () {

}

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpManager;

@end

@implementation SLAPIManager
@synthesize userEmail, userToken, baseURL, httpManager;

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Initialize variables
        userEmail = nil;
        userToken = nil;
        baseURL = nil;
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

+ (instancetype) sharedManager
{
    static SLAPIManager *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[SLAPIManager alloc] init];
        }
        return sharedSingleton;
    }
}

/*
 - (void) setBaseURL:(NSURL *)theBaseURL
 {
 baseURL = theBaseURL;
 }
 */

- (void) setEmail:(NSString *)theEmail
{
    userEmail = theEmail;
    [httpManager.requestSerializer setValue:self.userEmail forHTTPHeaderField:@"X-SL-Email"];
}

- (void) setToken:(NSString *)theToken
{
    self.userToken = theToken;
    [self.httpManager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-SL-Token"];
}

- (void) performRequestWithMethod:(SLHTTPMethodType)theMethod withPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLRequestCallback)theCallback
{
    AFHTTPRequestOperationManager *requestManager = self.httpManager;
    NSLog(@"requestManager: %@", requestManager);
    
    if (self.baseURL == nil)
    {
        @throw SLExceptionMissingBaseUrl;
    }
    
    NSLog(@"baseURl: %@", self.baseURL);
    NSLog(@"thePath: %@", thePath);
    NSURL *fullPath = [NSURL URLWithString:thePath relativeToURL:baseURL];
    NSString *fullPathStr = [fullPath absoluteString];
    NSLog(@"Full path: %@", fullPathStr);
    
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


- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword withCallback:(SLSuccessCallback)theCallback;
{
    if (theEmail != nil && thePassword != nil )
    {
        
        [self performRequestWithMethod:SLHTTPMethodPOST withPath:@"authenticate" withParameters:@{@"email":theEmail, @"password":thePassword} withCallback:^(NSError *error, id operation, id responseObject) {
            if (error == nil )
            {
                // Store the token
                NSDictionary *response = (NSDictionary *)responseObject;
                [self setEmail:response[@"email"]];
                [self setToken:response[@"token"]];
                
                theCallback(true);
            } else
            {
                theCallback(false);
            }
        }];
    } else
    {
        theCallback(false);
    }
}

- (void) authenticateWithUser:(SLUser *)theUser
                 withCallback:(SLSuccessCallback)theCallback
{
    [self authenticateWithUserEmail:[theUser get:@"email"] withPassword:[theUser get:@"password"] withCallback:theCallback];
}


@end
