//
//  NSString+SLStringHelpers.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "NSString+SLStringHelpers.h"

@implementation NSString (SLStringHelpers)

- (NSString *) underscore {
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    BOOL previousCharacterWasUppercase = FALSE;
    BOOL currentCharacterIsUppercase = FALSE;
    unichar currentChar = 0;
    unichar previousChar = 0;
    for (NSInteger idx = 0; idx < [self length]; idx += 1) {
        previousChar = currentChar;
        currentChar = [self characterAtIndex:idx];
        previousCharacterWasUppercase = currentCharacterIsUppercase;
        currentCharacterIsUppercase = [uppercase characterIsMember:currentChar];
        
        if (!previousCharacterWasUppercase && currentCharacterIsUppercase && idx > 0) {
            // insert an _ between the characters
            [output appendString:@"_"];
        } else if (previousCharacterWasUppercase && !currentCharacterIsUppercase) {
            // insert an _ before the previous character
            // insert an _ before the last character in the string
            if ([output length] > 1) {
                unichar charTwoBack = [output characterAtIndex:[output length]-2];
                if (charTwoBack != '_') {
                    [output insertString:@"_" atIndex:[output length]-1];
                }
            }
        }
        // Append the current character lowercase
        [output appendString:[[NSString stringWithCharacters:&currentChar length:1] lowercaseString]];
    }
    return output;
}

@end
