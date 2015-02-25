//
//  Deck.m
//  iRazz
//
//  Created by Ryou Inoue on 2014/09/24.
//  Copyright (c) 2014年 cat. All rights reserved.
//

#import "Deck.h"

@implementation Deck


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.deck = [NSMutableArray array];
        
        int i;
        int d52[DECK_SIZE] = {0};
        
        for ( i = 0; i < DECK_SIZE; i++ ) {
            // 1から52までの一様乱数を発生させる */
            int n = arc4random_uniform(DECK_SIZE);
            //           NSLog(@"%2d回目 = %2d", i + 1, n);
            
            while (d52[n] != 0) {
                n++;
                if (n > DECK_SIZE) {
                    n = 0;
                }
            }
            [self.deck addObject:[[Card alloc] initWithCardNumber:n]];
            d52[n]=1;
        }
        
    }
    return self;
}

- (void) check_deck
{
    for (int i = 0; i < DECK_SIZE; i++) {
        Card *card = [self.deck objectAtIndex:i];
        NSLog(@"%2@", card.displayString);
    }
}

- (Card *) getCard:(NSInteger) atIndex
{
    return [self.deck objectAtIndex:atIndex];
}


//アーカイブされたファイルからオブジェクトの状態を復元するときに呼ばれるメソッド
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.deck = [decoder decodeObjectForKey:@"deck"];
    }
    return self;
}

//オブジェクトをアーカイブするときに呼ばれるメソッド
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.deck forKey:@"deck"];
}
@end
