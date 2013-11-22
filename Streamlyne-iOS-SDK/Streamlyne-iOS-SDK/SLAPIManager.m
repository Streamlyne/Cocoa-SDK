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
    /**
     
     */
    AFHTTPRequestOperationManager *httpManager;
}

@end

@implementation SLAPIManager

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Initialize variables
        userEmail = nil;
        userToken = nil;
        baseURL = nil;
        httpManager = [AFHTTPRequestOperationManager manager];
        httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        [httpManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
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

- (void) setBaseURL:(NSURL *)theBaseURL
{
    self->baseURL = theBaseURL;
}

- (void) setEmail:(NSString *)theEmail
{
    self->userEmail = theEmail;
    [self->httpManager.requestSerializer setValue:self->userEmail forHTTPHeaderField:@"X-SL-Email"];
}

- (void) setToken:(NSString *)theToken
{
    self->userToken = theToken;
    [self->httpManager.requestSerializer setValue:self->userToken forHTTPHeaderField:@"X-SL-Token"];
}

- (void) performPostRequestWithPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLSuccessCallback)theCallback
{
    [self performRequestWithMethod:SLHTTPMethodPOST withPath:thePath withParameters:theParams withCallback:theCallback];
}

- (void) performRequestWithMethod:(SLHTTPMethodType)theMethod withPath:(NSString *)thePath withParameters:(NSDictionary *)theParams withCallback:(SLSuccessCallback)theCallback
{

    if (self->baseURL == nil)
    {
        @throw SLExceptionMissingBaseUrl;
    }
    
    NSLog(@"thePath: %@", thePath);
    NSURL *fullPath = [NSURL URLWithString:thePath relativeToURL:baseURL];
    NSLog(@"Full path: %@", [fullPath absoluteString]);
    
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
            [self->httpManager GET:[fullPath absoluteString] parameters:@{@"p":encodedJson} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                if (theCallback != nil) {
                    theCallback(true);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                NSLog(@"Response: %@", operation.responseString);
                if (theCallback != nil) {
                    theCallback(true);
                }
            }];
        }
            break;
        case SLHTTPMethodPOST:
        {
            [self->httpManager POST:[fullPath absoluteString] parameters:theParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
            break;
        default:
            @throw SLExceptionImplementationNotFound;
            break;
    }
}


- (void) authenticateWithUserEmail:(NSString *)theEmail withPassword:(NSString *)thePassword
{
    [self performPostRequestWithPath:@"authenticate" withParameters:@{@"email":theEmail, @"password":thePassword} withCallback:nil];
}

@end
