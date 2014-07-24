//
//  SLAPI.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <PromiseKit.h>
#import "SLObject.h"
#import "SLStore.h"

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


@interface SLAdapter : SLObject {
    
}

@property (strong, nonatomic, setter=setEmail:) NSString *userEmail;
@property (strong, nonatomic, setter=setPassword:) NSString *userPassword;
@property (strong, nonatomic, setter=setOrganization:) NSString *userOrganization;


/**
 SHA-1 encoding of a plain text string.
 */
+(NSString *) sha1:(NSString *)plainText;

/**
 HMAC encoding of a plain text string with a secret key.
 */
+(NSString *)hmac:(NSString *)plainText withSecret:(NSString *)secret;


/**
 Host for creating URL.
 See https://developer.apple.com/library/Mac/documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html#jumpTo_31 for more details.
 */
@property (strong, nonatomic) NSString *host;

/**
 Returns the Shared Adapter instance of `SLAdapter`.
 */
+ (instancetype) sharedAdapter;

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

/**
 The find() method is invoked when the store is asked for a record that has not previously been loaded. In response to find() being called, you should query your persistence layer for a record with the given ID. Once found, you can asynchronously call the store's push() method to push the record into the store.
 */
- (PMKPromise *) find:(Class)modelClass withId:(SLNid)nid withStore:(SLStore *)store;

/**
 Serializes the record and send it to the server.
 */
- (PMKPromise *) createRecord:(Class)modelClass withId:(SLNid)nid withStore:(SLStore *)store;
/*
 Serializes the record update and send it to the server.
 */
- (PMKPromise *) updateRecord:(SLModel *)record withStore:(SLStore *)store;

/**
 Sends a delete request for the record to the server.
 */
- (PMKPromise *) deleteRecord:(SLModel *)record withStore:(SLStore *)store;
/**
 Called by the store in order to fetch a JSON array for all of the records for a given type.
 
 The findAll method makes an Ajax (HTTP GET) request to a URL computed by buildURL, and returns a promise for the resulting payload.
 */
- (PMKPromise *) findAll:(Class)modelClass withStore:(SLStore *)store;
/**
 This method is called when you call find on the store with a query object as the second parameter (i.e. store.find('person', { page: 1 })).
 */
- (PMKPromise *) findQuery:(Class)modelClass withQuery:(NSDictionary *)query withStore:(SLStore *)store;
/**
 Find multiple records at once.
*/
- (PMKPromise *) findMany:(Class)modelClass withIds:(NSSet *)ids withStore:(SLStore *)store;

/**
 Proxies to the serializer's serialize method.
  */
- (NSDictionary *) serialize:(NSDictionary *)options;

/**
 Builds a URL for a given type and optional ID.
 
 By default, it pluralizes the type's name (for example, 'post'
 becomes 'posts' and 'person' becomes 'people'). To override the
 pluralization see [pathForType](#method_pathForType).
 
 If an ID is specified, it adds the ID to the path generated
 for the type, separated by a `/`.
 
 @method buildURL
 @param {String} type
 @param {String} id
 @return {String} url
 */
- (NSString *) buildURL:(Class)modelClass;


/**
 Builds a URL for a given type and optional ID.
 
 By default, it pluralizes the type's name (for example, 'post'
 becomes 'posts' and 'person' becomes 'people'). To override the
 pluralization see [pathForType](#method_pathForType).
 
 If an ID is specified, it adds the ID to the path generated
 for the type, separated by a `/`.
 
 @method buildURL
 @param {String} type
 @param {String} id
 @return {String} url
 */
- (NSString *) buildURL:(Class)modelClass withId:(SLNid)nid;


@end
