//
//  Card.m
//  iRazz
//
//  Created by Ryou Inoue on 8/29/14.
//  Copyright (c) 2014 cat. All rights reserved.
//

#import "Card.h"

@interface Card()
// 自分自身の中では変更可能にする
@property (strong, readwrite) NSString *displayString;     ///< NSString.
@property (readwrite) NSInteger rank;  ///< localized value.
@property (readwrite) NSInteger suit;  ///< localized value.
@end


@implementation Card

/*
 * 0 - 12 : A♠ - K♠
 * 13 - 25 : A♥ - K♥
 * 26 - 38 : A♦ - K♦
 * 39 - 51 : A♣ - K♣
 */
- (id)initWithCardNumber:(NSInteger) number
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.suit = number / 13;
        self.rank = number % 13 + 1; /* 0-12なので、+1して1-13にする */

        NSString *suit = [self getCardSuit];
        
        NSString *rank;
        if ((self.rank >= 2) && (self.rank <= 9)) {
            rank = [NSString stringWithFormat:@"%ld", (long)self.rank];
        } else if (self.rank == 1) {
            rank = @"A";
        } else if (self.rank == 10) {
            rank = @"T";
        } else if (self.rank == 11) {
            rank = @"J";
        } else if (self.rank == 12) {
            rank = @"Q";
        } else if (self.rank == 13) {
            rank = @"K";
        } else {
            assert("");
        }
        self.displayString = [[rank stringByAppendingString:@"\n"] stringByAppendingString:suit];
    }
    return self;
}


/*
 * 0:♠
 * 1:♥
 * 2:♦
 * 3:♣
 */
- (NSString *) getCardSuit
{
    switch (self.suit) {
        case 0:
            return [NSString stringWithFormat:@"♠"];
        case 1:
            return [NSString stringWithFormat:@"♥"];
        case 2:
            return [NSString stringWithFormat:@"♦"];
        case 3:
            return [NSString stringWithFormat:@"♣"];
        default:
            assert("");
            break;
    }
    return @"";
}

/*
 @retval    0     CardAが強い
 @retval    1     CardBが強い
 弱い Ks < Kh < Kd < Kc < Qs < .... < 2c < As < Ah < Ad < Ac 強い
 同じカードを比較する機能はありません。
 同じカードを比較すると、1が返ってきます。
 */
- (NSInteger) judgeRazzCardA:(Card *)cardA CardB:(Card *)cardB;
{
    if (cardA.rank == cardB.rank) {
        if (cardA.suit > cardB.suit) {
            return 0;
        }
        else {
            return 1;
        }
        
    } else {
        if (cardA.rank > cardB.rank) {
            return 1;
        }
        else {
            return 0;
        }
    }
    return 0;
}


//アーカイブされたファイルからオブジェクトの状態を復元するときに呼ばれるメソッド
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.displayString = [decoder decodeObjectForKey:@"displayString"];
        self.rank = [decoder decodeIntForKey:@"rank"];
        self.suit = [decoder decodeIntForKey:@"suit"];
    }
    return self;
}

//オブジェクトをアーカイブするときに呼ばれるメソッド
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.displayString forKey:@"displayString"];
    [encoder encodeInt:(int)self.rank forKey:@"rank"];
    [encoder encodeInt:(int)self.suit forKey:@"suit"];
}

@end
