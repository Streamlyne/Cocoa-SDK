//
//  SLValue.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//
#import "SLSDK.h"

/** --------------------------------------------------------------------------------
 */
@interface SLValue : NSObject {
    
    /**
     Stores the type of the encapsulated value.
     ex ) NSString, int, Boolean
     */
@private
    id type;
    
    /**
     Stores the current value of the SLValue. The value should be
     type unspecific.
     */
@private
    id value;
    
    /**
     */
@private
    id savedValue;
    
    /**
     A list of unary functions that values must "pass" to set.
     */
@private
    NSArray *predicates;
    
    /**
     Tracks wether {setSaved} has been called since the last
     successful call of {set}.
     */
@private
    BOOL *saved;
}


/**
 */
- initWithType:(id)type;


/**
 */
- initWithType:(id)type withValue:(id)value;


/**
 Sets the value of this {SLValue}.
 
 Given the value runtime check that {theValue} is of type
 {type}. If this is true iterate through all stored predicates
 passing {theValue} as the arguement.
 
 If all predicates return true, set {value} equal to {theValue}
 and set {saved} equal to false.
 */
- (BOOL) set:(id) theValue;


/**
 Returns the current {value}.
 */
- (id) get;


/**
 Returns the value of saved.
 */
- (BOOL) isSaved;


/**
 Set saved equal to true. This does not garuantee that the value
 has been persisted.
 */
- (void) setSaved;


/**
 Adds {predicate} to {predicates}. {predicate} should be an
 ObjC block.
 */
- (void) addPredicate: (NSPredicate *) predicate;

@end