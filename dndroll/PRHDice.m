//
//  PRHDice.m
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//

#import "PRHDice.h"

@implementation PRHDice
{
	NSInteger _numSides, _numDice;
	bool _omitLowestDie, _omitHighestDie;
}

+ (instancetype) newWithDescription:(NSString *)desc {
	return [[self alloc] initWithDescription:desc];
}
- (instancetype) initWithDescription:(NSString *)desc {
	if ((self = [super init])) {
		NSScanner *scanner = [NSScanner scannerWithString:desc];

		bool gotCount = [scanner scanInteger:&_numDice];
		if (gotCount) gotCount = (_numDice > 0);

		bool gotD = [scanner scanString:@"d" intoString:NULL];

		bool gotSides = [scanner scanInteger:&_numSides];
		if (gotSides) gotSides = (_numSides > 0);

		if ( ! (gotCount && gotD && gotSides) ) {
			self = nil;
		} else {
			//Read -lowest and -highest in either order.
			bool tempLowest, tempHighest;
			while (
				(
					(tempLowest = [scanner scanString:@"-lowest" intoString:NULL])
					&& (_omitLowestDie = tempLowest)
				) || (
					(tempHighest = [scanner scanString:@"-highest" intoString:NULL])
					&& (_omitHighestDie = tempHighest)
				)
			);

			if ((_numDice > 0) && (_numDice <= (_omitLowestDie + _omitHighestDie))) {
				NSLog(@"Can't roll %tu dice (%tud%tu) and then exclude %u of them",
					_numDice,
					_numDice, _numSides,
					(unsigned int)(_omitLowestDie + _omitHighestDie)
				);
				self = nil;
			}
		}
	}
	return self;
}

- (NSArray *) roll {
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:_numDice];

	for (NSInteger i = 0; i < _numDice; ++i) {
		[results addObject:@(arc4random_uniform((uint32_t)_numSides) + 1)];
	}

	if (_omitLowestDie) {
		NSNumber *lowestDie = [results valueForKeyPath:@"@min.integerValue"];

		//Remove exactly one. removeObject: will remove ALL matches.
		NSUInteger idx = [results indexOfObject:lowestDie];
		[results removeObjectAtIndex:idx];
	}
	if (_omitHighestDie) {
		NSNumber *highestDie = [results valueForKeyPath:@"@max.integerValue"];

		//Remove exactly one. removeObject: will remove ALL matches.
		NSUInteger idx = [results indexOfObject:highestDie];
		[results removeObjectAtIndex:idx];
	}

	return [results copy];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%tdd%td%@%@",
		_numDice,
		_numSides,
		_omitLowestDie ? @"-lowest" : @"",
		_omitHighestDie ? @"-highest" : @""
	];
}

@end
