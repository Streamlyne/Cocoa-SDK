//
//  SLValue.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"

/** --------------------------------------------------------------------------------
 */
@interface SLValue : SLObject {
    
    /**
     Stores the type of the encapsulated value.
     ex ) NSString, int, Boolean
     */
@private
    Class type;
    
    /**
     Stores the current value of the SLValue. The value should be
     type unspecific.
     */
@private
    id<NSObject> value;
    
    /**
     Stores the last saved value of the SLValue. The value should be
     type unspecific.
     */
@private
    id<NSObject> savedValue;
    
    /**
     A list of unary functions that values must "pass" to set.
     */
@private
    NSMutableArray *predicates;
    
    /**
     Tracks wether {setSaved} has been called since the last
     successful call of {set}.
     */
@private
    BOOL saved;
}


/**
 Initializes `SLValue` with type.
 @param theType     The type.
 @return
 */
- (instancetype) initWithType:(Class)theType;


/**
 Initializes `SLValue` with type and value.
 @param theType     The type.
 @param theValue    The value.
 @return
 */
- (instancetype) initWithType:(Class)theType withValue:(id)theValue;

/**
 Initializes `SLValue` with type and value and predicates.
 @param theType     The type.
 @param theValue    The value.
 @param thePredicates   The predicates.
 @return
 */
- (instancetype) initWithType:(Class)theType withValue:(id)theValue withPredicates:(NSArray *)thePredicates;

/**
 Returns the current {value}.
 @return
 */
- (id) get;


/**
 Sets the value of this {SLValue}.
 
 Given the value runtime check that {theValue} is of type
 {type}. If this is true iterate through all stored predicates
 passing {theValue} as the arguement.
 
 If all predicates return true, set {value} equal to {theValue}
 and set {saved} equal to false.

 @param theValue    The value.
 @return
 */
- (BOOL) set:(id) theValue;

/**
 Discard the changes and sets the {value} to {savedValue}.
 */
- (BOOL) discardChanges;

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