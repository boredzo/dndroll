//
//  main.m
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//


#import "PRHRoller.h"
#import "PRHDice.h"

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
