//
//  PRHRoller.h
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//

@interface PRHRoller: NSObject

///Parse something like “2d6+1d10+8” into an array of terms. Each is either a PRHDice or an NSNumber.
- (NSArray *) termsFromArgument:(NSString *)arg;
///Go through an array and roll all PRHDice. For every NSNumber in the input, the result contains the same NSNumber. For every PRHDice, the result has an array of the results of rolling those dice.
- (NSArray *) rollDiceSpecifiedByTerms:(NSArray *)terms;
///Go through an array of roll results and single numbers and sum each array of roll results. For every NSNumber and every NSArray of NSNumbers, the result contains an NSNumber.
- (NSArray *) sumRollsInRollResults:(NSArray *)results;

///Used by the main function's argument-consumption loop.
- (void) processAndEmptyTerms:(NSMutableArray *)allTerms;

@end
