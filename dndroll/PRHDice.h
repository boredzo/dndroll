//
//  PRHDice.h
//  dndroll
//
//  Created by Peter Hosey on 2014-07-26.
//  Copyright (c) 2014 Peter Hosey. All rights reserved.
//

@interface PRHDice: NSObject

+ (instancetype) newWithDescription:(NSString *)desc;
- (instancetype) initWithDescription:(NSString *)desc;

- (NSArray *) roll;

@end
