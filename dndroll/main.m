//
//  main.m
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//


#import "PRHRoller.h"
#import "PRHDice.h"

static void selftest(PRHRoller *roller);

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSEnumerator *argsEnum = [[[NSProcessInfo processInfo] arguments] objectEnumerator];
		[argsEnum nextObject];
		PRHRoller *roller = [PRHRoller new];

		NSMutableArray *allTerms = [NSMutableArray arrayWithCapacity:argc];
		bool justProcessedTerm = false;
		for (NSString *arg in argsEnum) {
			if ([@"+" isEqualToString:[arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ]) {
				justProcessedTerm = false;
				continue;
			} else if ([arg isEqualToString:@"selftest"]) {
				[roller processAndEmptyTerms:allTerms];
				selftest(roller);
				justProcessedTerm = false;
				continue;
			} else if (justProcessedTerm) {
				[roller processAndEmptyTerms:allTerms];
			}

			NSArray *terms = [roller termsFromArgument:arg];
			if (allTerms.count > 0 && [[terms firstObject] isEqual:@0]) {
				//Don't allow + prefixes if we aren't starting a new descriptor
				terms = [terms subarrayWithRange:(NSRange){ 1, terms.count - 1 }];
			}
			[allTerms addObjectsFromArray:terms];
			justProcessedTerm = true;
		}
		if (allTerms.count > 0) {
			[roller processAndEmptyTerms:allTerms];
		}
	}
    return EXIT_SUCCESS;
}

static NSNumber *selftestDiceWithNumberOfSides(PRHRoller *roller, NSUInteger numSides);

static void selftest(PRHRoller *roller) {
	void (^test)(NSUInteger) = ^(NSUInteger numSides) {
		NSLog(@"Self-test: Rolling 100000d%tu ten times (bar lengths should be as equal as possible)", numSides);
		NSArray *stddevs = @[
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
			selftestDiceWithNumberOfSides(roller, numSides),
		];
		NSLog(@"100000d%tu: Average std. dev.: %@ (%f%%)", numSides, [stddevs valueForKeyPath:@"@avg.doubleValue"], [[stddevs valueForKeyPath:@"@avg.doubleValue"] doubleValue] / 100.0);
		NSExpression *stddevOfStddev = [NSExpression expressionForFunction:@"stddev:" arguments:@[ [NSExpression expressionForConstantValue:stddevs] ]];
		NSNumber *result = [stddevOfStddev expressionValueWithObject:nil context:nil];
		NSLog(@"100000d%tu: Std. dev. of std. dev.: %@ (%f%%)", numSides, result, result.doubleValue / 100.0);
	};
	test(4);
	test(6);
	test(8);
	test(10);
	test(12);
	test(20);
}

//Returns standard deviation.
static NSNumber *selftestDiceWithNumberOfSides(PRHRoller *roller, NSUInteger numSides) {
	const char *barUTF8 = [@"▓" UTF8String];
	const char *emptyBarUTF8 = [@"░" UTF8String];
	NSUInteger numDice = 100000;
	NSArray *oneThousandDice = [roller termsFromArgument:[NSString stringWithFormat:@"%tud%tu", numDice, numSides]];
	NSArray *oneThousandRolls = [[roller rollDiceSpecifiedByTerms:oneThousandDice] firstObject];
	NSMutableArray *counts = [NSMutableArray arrayWithCapacity:numSides];
	for (NSUInteger i = 1; i <= numSides; ++i) {
		NSNumber *iNum = @(i);
		NSArray *matches = [oneThousandRolls filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"integerValue = %@", iNum]];
		NSUInteger numMatches = matches.count;
		[counts addObject:@(numMatches)];
	}
	for (NSNumber *countNum in counts) {
		NSUInteger numMatches = countNum.integerValue;
		//Print bars 50 characters long.
		static const NSUInteger maxBarLength = 50;
		NSUInteger barLength = numMatches / (numDice / maxBarLength);
		NSUInteger j = 0;
		for (; j < barLength; ++j) {
			fputs(barUTF8, stdout);
		}
		for (; j < maxBarLength; ++j) {
			fputs(emptyBarUTF8, stdout);
		}
		fputc('\n', stdout);
	}

	NSExpression *stddev = [NSExpression expressionForFunction:@"stddev:" arguments:@[ [NSExpression expressionForConstantValue:counts] ]];
	NSNumber *stddevResult = [stddev expressionValueWithObject:nil context:nil];
	NSLog(@"Standard deviation of %tu rolls: %@ (%f%%)", numDice, stddevResult, stddevResult.doubleValue / 100.0);
	return stddevResult;
}
