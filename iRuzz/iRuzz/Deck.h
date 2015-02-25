//
//  Deck.h
//  iRazz
//
//  Created by Ryou Inoue on 2014/09/24.
//  Copyright (c) 2014年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject<NSCoding>

#define DECK_SIZE 52 /* 52枚 */

@property(strong, nonatomic, readwrite) NSMutableArray *deck; /* 52枚のデッキにする */

- (void) check_deck;
- (Card *) getCard:(NSInteger) atIndex;

@end
