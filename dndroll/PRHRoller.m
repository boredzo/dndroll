//
//  PRHRoller.m
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//

#import "PRHRoller.h"

#import "PRHDice.h"

@implementation PRHRoller

- (NSArray *) termsFromArgument:(NSString *)arg {
	NSArray *termStrings = [arg componentsSeparatedByString:@"+"];
	NSMutableArray *diceAndNumbers = [NSMutableArray arrayWithCapacity:termStrings.count];

	for (NSString *term in termStrings) {
		//term is either something like 1d6 or a single number
		id obj = [PRHDice newWithDescription:term];
		if (obj == nil) {
			if ([@"" isEqual:obj]) {
				//If this is the first term, arg starts with +, like “+4” or “+1d6+7”
				obj = @0;
			} else {
				obj = [term valueForKey:@"integerValue"];
			}
		}
		if (obj == nil) {
			NSLog(@"Couldn't parse term %@ (must be either NdM or a single number)", term);
		}
		[diceAndNumbers addObject:obj];
	}

	return diceAndNumbers;
}

- (NSArray *) rollDiceSpecifiedByTerms:(NSArray *)terms {
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:terms.count];
	for (id obj in terms) {
		if ([obj respondsToSelector:@selector(roll)]) {
			[results addObject:[obj roll]];
		} else if ([obj isKindOfClass:[NSNumber class]]) {
			[results addObject:obj];
		}
	}
	return results;
}

- (NSArray *) sumRollsInRollResults:(NSArray *)inResults {
	NSMutableArray *summedResults = [NSMutableArray arrayWithCapacity:inResults.count];
	for (id obj in inResults) {
		if ([obj isKindOfClass:[NSArray class]]) {
			[summedResults addObject:[obj valueForKeyPath:@"@sum.integerValue"]];
		} else if ([obj isKindOfClass:[NSNumber class]]) {
			[summedResults addObject:obj];
		}
	}
	return summedResults;

}

- (void) processAndEmptyTerms:(NSMutableArray *)allTerms {
	NSArray *rawResults = [self rollDiceSpecifiedByTerms:allTerms];
	NSArray *summedResults = [self sumRollsInRollResults:rawResults];
	bool shouldPrintPlusSeparator = false;
	for (NSUInteger i = 0, count = summedResults.count; i < count; ++i) {
		id diceOrNumber = allTerms[i];
		if ([diceOrNumber isKindOfClass:[PRHDice class]]) {
			printf("%s", shouldPrintPlusSeparator ? "+" : "");
			id rollsOrNumber = rawResults[i];
			NSString *rollsOrNumberDesc = nil;
			if ([rollsOrNumber respondsToSelector:@selector(componentsJoinedByString:)]) {
				rollsOrNumberDesc = [rollsOrNumber componentsJoinedByString:@"+"];
			} else {
				rollsOrNumberDesc = [rollsOrNumber description];
			}
			NSNumber *sumOfTerm = summedResults[i];
			printf("(%s=%s=%s)",
				[diceOrNumber description].UTF8String,
				[rollsOrNumberDesc description].UTF8String,
				[sumOfTerm description].UTF8String);
			shouldPrintPlusSeparator = true;
		} else if (i == 0 && [diceOrNumber isEqual:@0]) {
			//+ prefix (when the descriptor started with +)
			printf("%s", "+");
			shouldPrintPlusSeparator = false;
		} else {
			//Single number
			printf("%s", shouldPrintPlusSeparator ? "+" : "");
			printf("%td", [diceOrNumber integerValue]);
			shouldPrintPlusSeparator = true;
		}
	}
	printf("=%s\n", [[summedResults valueForKeyPath:@"@sum.integerValue"] description].UTF8String);

	[allTerms removeAllObjects];
}

@end
