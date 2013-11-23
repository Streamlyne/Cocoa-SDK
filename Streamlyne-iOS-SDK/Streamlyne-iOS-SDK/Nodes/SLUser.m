//
//  SLUser.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLUser.h"
#import "SLValue.h"

#import "SLAPIManager.h"

@implementation SLUser

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *email = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *password = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *jobTitle = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *firstName = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *lastName = [[SLValue alloc]initWithType:[NSString class]];
        // Edit data schema
        NSMutableDictionary *tempData = [self->data mutableCopy];
        [tempData setValue:email forKey:@"email"];
        [tempData setValue:password forKey:@"password"];
        [tempData setValue:jobTitle forKey:@"job_title"];
        [tempData setValue:firstName forKey:@"name_first"];
        [tempData setValue:lastName forKey:@"name_last"];
        self->data = tempData;
    }
    return self;
}

+ (NSString *) type
{
    return @"user";
}

+ (void) registerUser:(SLUser *)theUser withCallback:(SLSuccessCallback)theCallback
{
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        NSLog(@"SLRequestCallback completionBlock!");
        NSLog(@"<%@>: %@", [responseObject class], responseObject);
        theCallback ? theCallback(true) : nil;
    };
    
    NSDictionary *jsonQuery = @{
                                @"data": @{
                                        },
                                @"rels": @[
                                        [NSNumber numberWithBool:TRUE]
                                        ]
                                };
    /*
    'data': {
        'email': '{0}@streamlyne.co'.format(generateRandomString(6)),
        'password': 'asdfasdf',
        'job_title': 'developer',
        'name_first': 'Testy',
        'name_last': 'Tester'
    },
    'rels': [
             {
                 'id': organizationId,
                 'dir': 'out',
                 'nodeType': 'organization',
                 'relsType': 'member'
             }
             ]
*/
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodPOST withPath:[[self class] type] withParameters:jsonQuery withCallback:completionBlock];

}


@end
