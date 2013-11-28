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

@implementation SLUser

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *email = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *password = [[SLValue alloc]initWithType:[NSString class]];
        [password setClientVisible:FALSE]; // Will not be visible to client when reading `SLUser` nodes.
        SLValue *phoneNumber = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *jobTitle = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *firstName = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *lastName = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *avatar = [[SLValue alloc]initWithType:[NSURL class]];
        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        [tempData setValue:email forKey:@"email"];
        [tempData setValue:password forKey:@"password"];
        //[tempData setValue:phoneNumber forKey:@"phone_number"];
        [tempData setValue:jobTitle forKey:@"job_title"];
        [tempData setValue:firstName forKey:@"name_first"];
        [tempData setValue:lastName forKey:@"name_last"];
        //[tempData setValue:avatar forKey:@"avatar"];
        self.data = tempData;
    }
    return self;
}

+ (NSString *) type
{
    return @"user";
}

+ (void) registerUser:(SLUser *)theUser withOrganization:(SLOrganization *)theOrg withCallback:(SLSuccessCallback)theCallback
{
    /*
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        //NSLog(@"SLRequestCallback completionBlock!");
        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
        theCallback ? theCallback(true) : nil;
    };
     */
    SLRelationship *rel = [[SLRelationship alloc] initWithName:@"member" withStartNode:theUser withEndNode:theOrg];
    [theUser saveWithCallback:theCallback];
}


+ (void) registerUserWithEmail:(NSString *)email
                  withPassword:(NSString *)password
                  withJobTitle:(NSString *)jobTitle
                 withFirstName:(NSString *)firstName
                  withLastName:(NSString *)lastName
              withOrganization:(SLOrganization *)theOrg
                  withCallback:(SLSuccessCallback)theCallback
{
    NSDictionary *data = @{
                           @"email": email,
                           @"password": password,
                           @"job_title": jobTitle,
                           @"name_first": firstName,
                           @"name_last": lastName
                       };
    SLUser *newUser = [SLUser createWithData:data
                                    withRels:(SLRelationshipArray *)@[]];
    [[self class] registerUser:newUser withOrganization:theOrg withCallback:theCallback];
}

@end
