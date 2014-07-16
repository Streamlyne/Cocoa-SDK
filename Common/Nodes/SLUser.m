//
//  SLUser.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLUser.h"
#import "SLValue.h"
#import "SLRelationship.h"
#import "SLAPIManager.h"

@implementation SLUser


@dynamic email;
@dynamic jobTitle;
@dynamic firstName;
@dynamic lastName;
@dynamic password;

+ (NSString *) type
{
    return @"user";
}


+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"jobTitle" forKey:@"job_title"];
    [attrMap setValue:@"firstName" forKey:@"name_first"];
    [attrMap setValue:@"lastName" forKey:@"name_last"];
    [attrMap setValue:@"dateCompleted" forKey:@"description"];
    [attrMap setValue:@"costCenter" forKey:@"cost_center"];
    [attrMap setValue:@"dateDue" forKey:@"date_due"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}
//
//+ (void) registerUser:(SLUser *)theUser withOrganization:(SLOrganization *)theOrg withCallback:(SLSuccessCallback)theCallback
//{
//    /*
//    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
//        //NSLog(@"SLRequestCallback completionBlock!");
//        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
//        theCallback ? theCallback(true) : nil;
//    };
//     */
//    SLRelationship *rel = [[SLRelationship alloc] initWithName:@"member" withStartNode:theUser withEndNode:theOrg];
//    [theUser pushWithAPIManager:[SLAPIManager sharedManager] withCallback:theCallback];
//}
//
//
//+ (void) registerUserWithEmail:(NSString *)email
//                  withPassword:(NSString *)password
//                  withJobTitle:(NSString *)jobTitle
//                 withFirstName:(NSString *)firstName
//                  withLastName:(NSString *)lastName
//              withOrganization:(SLOrganization *)theOrg
//                  withCallback:(SLSuccessCallback)theCallback
//{
//    NSDictionary *data = @{
//                           @"email": email,
//                           @"password": password,
//                           @"job_title": jobTitle,
//                           @"name_first": firstName,
//                           @"name_last": lastName
//                       };
//    SLUser *newUser = [SLUser createWithData:data
//                                    withRels:(NSArray *)@[]];
//    [[self class] registerUser:newUser withOrganization:theOrg withCallback:theCallback];
//}

@end
