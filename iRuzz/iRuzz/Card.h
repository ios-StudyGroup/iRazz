//
//  Card.h
//  iRazz
//
//  Created by Ryou Inoue on 8/29/14.
//  Copyright (c) 2014 cat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RazzHand.h"

@interface Card : NSObject<NSCoding>
{
    NSString *_displayValue;
    NSInteger _rank;
    NSInteger _suit;
}

@property (strong, readonly) NSString *displayString;     ///< NSString.
@property (readonly) NSInteger rank;  ///< localized value.
@property (readonly) NSInteger suit;  ///< localized value.

- (id)initWithCardNumber:(NSInteger)number;
- (NSInteger) judgeRazzCardA:(Card *)cardA CardB:(Card *)cardB;

@end
