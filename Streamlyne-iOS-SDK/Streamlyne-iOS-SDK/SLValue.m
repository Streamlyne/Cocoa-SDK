//
//  SLValue.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLValue.h"

@implementation SLValue


- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        predicates = [NSMutableArray array];
        saved = NO;
        savedValue = NULL;
        value = NULL;
    }
    return self;
}

- (id) initWithType:(id)theType
{
    self = [self initWithType:theType withValue:nil withPredicates:nil];
    return self;
}

- (id) initWithType:(id)theType withValue:(id)theValue
{
    self = [self initWithType:theType withValue:theValue withPredicates:nil];
    return self;
}

- (id) initWithType:(id)theType withValue:(id)theValue withPredicates:(NSArray *)thePredicates {
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


- (id) get
{
    return value;
}

- (BOOL) set:(id)theValue
{
    // Validate
    if (true) { // TODO: Perform actual validation with predicates in SLValue.
        // Passed validation.
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
