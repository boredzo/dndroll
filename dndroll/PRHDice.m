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
		}
	}
	return self;
}

- (NSArray *) roll {
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:_numDice];
	for (NSInteger i = 0; i < _numDice; ++i) {
		[results addObject:@(arc4random_uniform((uint32_t)_numSides) + 1)];
	}
	return [results copy];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%tdd%td", _numDice, _numSides];
}

@end
