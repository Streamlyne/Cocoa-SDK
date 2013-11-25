//
//  SLValue.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLValue.h"

@implementation SLValue

@synthesize clientVisible;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        predicates = [NSMutableArray array];
        saved = NO;
        savedValue = nil;
        value = nil;
        clientVisible = true; // Default is true
    }
    return self;
}

- (instancetype) initWithType:(Class)theType
{
    self = [self initWithType:theType withValue:nil withPredicates:nil];
    return self;
}

- (instancetype) initWithType:(Class)theType withValue:(id)theValue
{
    self = [self initWithType:theType withValue:theValue withPredicates:nil];
    return self;
}

- (instancetype) initWithType:(Class)theType withValue:(id)theValue withPredicates:(NSArray *)thePredicates {
    self = [self init];
    if (self)
    {
        // Initialize variables
        self->type = theType;
        self->predicates = [NSMutableArray arrayWithArray:thePredicates];
        [self set:theValue];
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self, NSNullIfNil([self get]) ];
    
    /*
     return [NSString stringWithFormat:@"<%@: %@>", [self class],
            [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithBool:saved], @"saved",
             NSNullIfNil(savedValue), @"savedValue",
             NSNullIfNil(value), @"value",
             NSNullIfNil(predicates), @"predicates",
             nil
             ] ];
     */
    //return [NSString stringWithFormat:@"<%@: { saved: \"%@\", savedValue: %@, value: %@, predicates: %@ } >", [self class], [NSNumber numberWithBool:saved], savedValue, value, predicates];

}

- (id) get
{
    return value;
}

- (BOOL) set:(id)theValue
{
    // Validate
    BOOL isValid = true;
    if (self->value != nil && ! [theValue isKindOfClass:self->type])
    {
        isValid = false;
    }
    // TODO: Perform actual validation with predicates in SLValue.
    if (isValid) {
        // Passed validation.
        //NSLog(@"Set: %@", theValue);
        self->value = theValue;
        return true;
    } else {
        // Failed validation
        return false;
    }
}

- (BOOL) discardChanges
{
    // Set value to backup savedValue
    if ([self set:self->savedValue]) {
        // If successful, then mark this SLValue as saved.
        [self setSaved];
        return true;
    } else {
        return false;
    }
}

- (BOOL) isSaved
{
    return saved;
}

- (void) setSaved
{
    saved = YES;
}

- (void) addPredicate:(NSPredicate *)predicate
{
    [self->predicates addObject:predicate];
}

@end
