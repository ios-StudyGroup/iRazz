//
//  RazzHand.m
//  iRazz
//
//  Created by Ryou Inoue on 9/4/14.
//  Copyright (c) 2014 cat. All rights reserved.
//

// @todo MTをしないと・・・

#import "RazzHand.h"

#include <stdlib.h>

/* ソート関数 */
int int_sort( const void * a , const void * b ) {
    /* 引数はvoid*型と規定されているのでint型にcastする */
    if( *( int * )a < *( int * )b ) {
        return -1;
    }
    else
        if( *( int * )a == *( int * )b ) {
            return 0;
        }
    return 1;
}


@interface RazzHand ()
{
}
@end

@implementation RazzHand

/*
 @retval    0     HandAの勝ち
 @retval    1     HandBの勝ち
 @retval    2     引き分け
 @retval    -1    HandAとHandBの要素数が違う or ハンドが8枚以上ある
 @param  handA    Cardのアレイ
 @param  handB    Cardのアレイ
 */
- (NSInteger) judgeHandA:(NSArray *)handA HandB:(NSArray *)handB
{
    int handAOfR[HAND_SIZE] = {0};
    int handBOfR[HAND_SIZE] = {0};

    // 要素数チェック
    if (([handA count] != [handB count]) && ([handA count] <= HAND_SIZE)) {
        return -1;
    }

    int count = (int)[handA count];
    for (int i = 0; i < count; i++) {
        Card *tmp;
        tmp = (Card *)[handA objectAtIndex:i];
        handAOfR[i] = (int)tmp.rank;
        tmp = (Card *)[handB objectAtIndex:i];
        handBOfR[i] = (int)tmp.rank;
    }
    NSLog(@"Before");
    NSLog(@"handA=%2d,%2d,%2d,%2d,%2d,%2d,%2d\n", handAOfR[0], handAOfR[1], handAOfR[2], handAOfR[3], handAOfR[4], handAOfR[5], handAOfR[6]);
    NSLog(@"handB=%2d,%2d,%2d,%2d,%2d,%2d,%2d\n", handBOfR[0], handBOfR[1], handBOfR[2], handBOfR[3], handBOfR[4], handBOfR[5], handBOfR[6]);

    /* クイックソート */
    qsort( handAOfR, [handA count], sizeof(int), int_sort );
    qsort( handBOfR, [handB count], sizeof(int), int_sort );

    NSLog(@"After");
    NSLog(@"handA=%2d,%2d,%2d,%2d,%2d,%2d,%2d\n", handAOfR[0], handAOfR[1], handAOfR[2], handAOfR[3], handAOfR[4], handAOfR[5], handAOfR[6]);
    NSLog(@"handB=%2d,%2d,%2d,%2d,%2d,%2d,%2d\n", handBOfR[0], handBOfR[1], handBOfR[2], handBOfR[3], handBOfR[4], handBOfR[5], handBOfR[6]);

    switch(count) {
        case 2:
            return [self judgeHand2AInt:handAOfR HandBInt:handBOfR];
        case 3:
            return [self judgeHand3AInt:handAOfR HandBInt:handBOfR];
        case 4:
            return [self judgeHand4AInt:handAOfR HandBInt:handBOfR];
        case 7:
            return [self judgeHand7AInt:handAOfR HandBInt:handBOfR];
        default:
            assert("");
            return -1;
    }
}

/*
 * @retval    0     HandAの勝ち
 * @retval    1     HandBの勝ち
 * @retval    2     引き分け
 */
- (NSInteger) judgeHand2AInt:(int *)handA HandBInt:(int *)handB
{
    NSInteger pairCounterHandA = [self countPair_HP2:handA];
    NSInteger pairCounterHandB = [self countPair_HP2:handB];
    
    if (pairCounterHandA < pairCounterHandB) {
        return 0;
    } else if (pairCounterHandA > pairCounterHandB) {
        return 1;
    } else { // 引き分けなら、大きい数字から比較
        for (int i = 1; i >= 0; i--) {
            if (handA[i] > handB[i]) {
                return 1;
            }
            if (handA[i] < handB[i]) {
                return 0;
            }
        }
    }
    return 2;
}

/*
 * @retval    0     HandAの勝ち
 * @retval    1     HandBの勝ち
 * @retval    2     引き分け
 */
- (NSInteger) judgeHand3AInt:(int *)handA HandBInt:(int *)handB
{
    NSInteger pairCounterHandA = [self countPair_HP3:handA];
    NSInteger pairCounterHandB = [self countPair_HP3:handB];
    NSInteger threeKCounterHandA = [self count3K_HP3:handA];
    NSInteger threeKCounterHandB = [self count3K_HP3:handB];
    
    if (threeKCounterHandA < threeKCounterHandB) {
        return 0;
    } else if (threeKCounterHandA > threeKCounterHandB) {
        return 1;
    } else if (threeKCounterHandA == 1) {
        if (handA[0] < handB[0]) {
            return 0;
        } else {
            return 1;
        }
    } else {
        // 3Kなしパターン
    }
    
    if (pairCounterHandA < pairCounterHandB) {
        return 0;
    } else if (pairCounterHandA > pairCounterHandB) {
        return 1;
    } else if (pairCounterHandA == 1) {
        return [self judgeHP3_1P:handA Hand3B:handB];
    } else {// 引き分けなら、大きい数字から比較
        // Pなしパターン
    }
    
    for (int i = 2; i >= 0; i--) {
        if (handA[i] > handB[i]) {
            return 1;
        }
        if (handA[i] < handB[i]) {
            return 0;
        }
    }

    return 2;
}

/*
 * @retval    0     HandAの勝ち
 * @retval    1     HandBの勝ち
 * @retval    2     引き分け
 */
- (NSInteger) judgeHand4AInt:(int *)handA HandBInt:(int *)handB
{
    NSInteger hp4_handA = [self checkHP4:handA];
    NSInteger hp4_handB = [self checkHP4:handB];
    
    if (hp4_handA < hp4_handB) {
        return 0;
    } else if (hp4_handA > hp4_handB) {
        return 1;
    } else {
        switch (hp4_handA) {
            case HP4_0P:
                return [self judgeHP4_0P:handA Hand4B:handB];
            case HP4_1P:
                return [self judgeHP4_1P:handA Hand4B:handB];
            case HP4_2P:
                return [self judgeHP4_2P:handA Hand4B:handB];
            case HP4_3K:
                return [self judgeHP4_3K:handA Hand4B:handB];
            case HP4_4K:
                if (handA[0] < handB[0]) {
                    return 0;
                } else {
                    return 1;
                }
            default:
                assert("");
        }
    }
    return 0;
}


/*
 * @retval    0     HandAの勝ち
 * @retval    1     HandBの勝ち
 * @retval    2     引き分け
 */
- (NSInteger) judgeHand7AInt:(int *)handA HandBInt:(int *)handB
{
    const NSInteger hp7ToHp5[] = {HP5_0P, HP5_0P, HP5_0P, HP5_0P, HP5_1P, HP5_1P, HP5_1P, HP5_2P, HP5_2P, HP5_2P, HP5_FH};
    
    NSInteger hp7_handA = [self checkHP7:handA];
    NSInteger hp7_handB = [self checkHP7:handB];
    
    NSInteger hp5_handA = hp7ToHp5[hp7_handA];
    NSInteger hp5_handB = hp7ToHp5[hp7_handB];
    
    NSLog(@"hp7_handA=%2ld hp5_handA=%2ld", (long)hp7_handA, (long)hp5_handA);
    NSLog(@"hp7_handB=%2ld hp5_handB=%2ld", (long)hp7_handB, (long)hp5_handB);
    
    if (hp5_handA > hp5_handB) {
        return 1;
    } else if (hp5_handA < hp5_handB) {
        return 0;
    } else { /* 引き分けなグループ */
        int hand5A[5] = {0};
        int hand5B[5] = {0};
        
        [self getHand5:hand5A Hand7:handA HP7:hp7_handA];
        [self getHand5:hand5B Hand7:handB HP7:hp7_handB];
        
        NSLog(@"hand5A=%2d,%2d,%2d,%2d,%2d", hand5A[0], hand5A[1], hand5A[2], hand5A[3], hand5A[4]);
        NSLog(@"hand5B=%2d,%2d,%2d,%2d,%2d", hand5B[0], hand5B[1], hand5B[2], hand5B[3], hand5B[4]);
        
        switch (hp5_handA) {
            case HP5_0P:
                return [self judgeHP5_0P:hand5A Hand5B:hand5B];
            case HP5_1P:
                return [self judgeHP5_1P:hand5A Hand5B:hand5B];
            case HP5_2P:
                return [self judgeHP5_2P:hand5A Hand5B:hand5B];
            case HP5_FH:
                return [self judgeHP5_FH:hand5A Hand5B:hand5B];
            default:
                assert("");
        }
        return 2; // ここを通ることはないはず・・・
    }
}

/*
 * @return HP7
 */
- (NSInteger) checkHP7:(int *)hand
{
    NSInteger pairCounter = [self countPair_HP7:hand];
    NSInteger threeKCounter = [self count3K_HP7:hand];
    NSInteger fourKCounter = [self count4K_HP7:hand];
    
    const NSInteger One4K[2][2] = {{HP7_4K, HP7_4K1P}, {HP7_4K3K, -1}};
    const NSInteger No4K[3][4] = {{HP7_0P, HP7_1P, HP7_2P, HP7_3P}, { HP7_3K, HP7_3K1P, HP7_3K2P, -1}, { HP7_3K3K, -1, -1, -1}};
    
    if (fourKCounter == 1) {
        return One4K[threeKCounter][pairCounter];
    } else {
        return No4K[threeKCounter][pairCounter];
    }
}

/*
 * @return HP5
 */
- (NSInteger) checkHP5:(int *)hand
{
    // つかわんぽい
    return 0;
}

/*
 * @return HP4
 */
- (NSInteger) checkHP4:(int *)hand
{
    NSInteger pairCounter = [self countPair_HP4:hand];
    NSInteger threeKCounter = [self count3K_HP4:hand];
    NSInteger fourKCounter = [self count4K_HP4:hand];
    
    const NSInteger No4K[2][3] = {{HP4_0P, HP4_1P, HP4_2P}, { HP4_3K, -1, -1}};
    
    if (fourKCounter == 1) {
        return HP4_4K;
    } else {
        return No4K[threeKCounter][pairCounter];
    }
}

- (NSInteger) countPair_HP7:(int *)hand
{
    NSInteger pairCounter = 0;
    NSInteger threeKCounter = [self count3K_HP7:hand];
    NSInteger fourKCounter = [self count4K_HP7:hand];

    for (int i = 0; i < 6; i++) {
        if (hand[i] == hand[i + 1]) {
            pairCounter++;
        }
    }
    
    return (pairCounter - (threeKCounter * 2) - (fourKCounter * 3));
}

- (NSInteger) count3K_HP7:(int *)hand
{
    NSInteger threeKCounter = 0;
    NSInteger fourKCounter = [self count4K_HP7:hand];
    for (int i = 0; i < 5; i++) {
        if ( (hand[i] == hand[i + 1]) && (hand[i] == hand[i + 2])) {
            threeKCounter++;
        }
    }
    
    return (threeKCounter - (fourKCounter * 2));
}

- (NSInteger) count4K_HP7:(int *)hand
{
    NSInteger fourKCounter = 0;
    for (int i = 0; i < 4; i++) {
        if ( (hand[i] == hand[i + 1]) && (hand[i] == hand[i + 2]) && (hand[i] == hand[i + 3])) {
            fourKCounter++;
        }
    }

    return fourKCounter;
}

/*
 * @param HP5 要素5のint配列
 * @param HP7 要素7のint配列
 * @param hp7 HandPattern7の種類
 */
- (void) getHand5:(int *)hand5 Hand7:(int *)hand7 HP7:(NSUInteger)hp7
{
    switch (hp7) {
        case HP7_0P:
            [self getHand5HP7_0P:hand5 Hand7:hand7];
            break;
        case HP7_1P:
            [self getHand5HP7_1P:hand5 Hand7:hand7];
            break;
        case HP7_2P:
            [self getHand5HP7_2P:hand5 Hand7:hand7];
            break;
        case HP7_3K:
            [self getHand5HP7_3K:hand5 Hand7:hand7];
            break;
        case HP7_3P:
            [self getHand5HP7_3P:hand5 Hand7:hand7];
            break;
        case HP7_3K1P:
            [self getHand5HP7_3K1P:hand5 Hand7:hand7];
            break;
        case HP7_4K:
            [self getHand5HP7_4K:hand5 Hand7:hand7];
            break;
        case HP7_3K2P:
            [self getHand5HP7_3K2P:hand5 Hand7:hand7];
            break;
        case HP7_3K3K:
            [self getHand5HP7_3K3K:hand5 Hand7:hand7];
            break;
        case HP7_4K1P:
            [self getHand5HP7_4K1P:hand5 Hand7:hand7];
            break;
        case HP7_4K3K:
            [self getHand5HP7_4K3K:hand5 Hand7:hand7];
            break;
        default:
            assert("");
            break;
    }
}

-(void) getHand5HP7_0P:(int *)hand5 Hand7:(int *)hand7
{
    for (int i = 0; i < 5; i++) {
        hand5[i] = hand7[i];
    }
}

-(void) getHand5HP7_1P:(int *)hand5 Hand7:(int *)hand7
{
    // ペアがある場合は飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if (hand7[j] == hand7[j + 1]) {
            j++;
        }
    }
}

-(void) getHand5HP7_2P:(int *)hand5 Hand7:(int *)hand7
{
    // ペアがある場合は飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if (hand7[j] == hand7[j + 1]) {
            j++;
        }
    }
}

-(void) getHand5HP7_3K:(int *)hand5 Hand7:(int *)hand7
{
    // 3Kがある場合は2枚飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if ((hand7[j] == hand7[j + 1]) && (hand7[j] == hand7[j + 2]) ) {
            j = j + 2;
        }
    }
}

-(void) getHand5HP7_3P:(int *)hand5 Hand7:(int *)hand7
{
    // 最初ペアを有効とし、2つ目、3つ目は飛ばす
    int pairCount = 0;
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if (hand7[j] == hand7[j + 1]) {
            if (pairCount > 0) {
                j++;
            }
            pairCount++;
        }
    }
}

/*
 * 3Kのランク > 1Pのランク ならば 3Kを2枚抜く
 * 3Kのランク < 1Pのランク ならば 3Kを1枚、1Pを1枚抜く
 */
-(void) getHand5HP7_3K1P:(int *)hand5 Hand7:(int *)hand7
{
    // search 3K and 1P
    int rank3K = 0;
    int startPosition3K = 0;
    int rank1P = 0;
    int startPosition1P = 0;
    for (int i = 0; i < 5; i++) {
        if ((hand7[i] == hand7[i + 1]) && (hand7[i + 1] == hand7[i + 2])) {
            rank3K = hand7[i];
            startPosition3K = i;
        } else if ((hand7[i] == hand7[i + 1]) && (hand7[i + 1] != hand7[i + 2])) {
            rank1P = hand7[i];
            startPosition1P = i;
        } else {
            assert("");
        }
    }
    
    if (rank3K > rank1P) {
        int j = 0;
        for (int i = 0; i < 5; i++, j++) {
            hand5[i] = hand7[j];
            if (startPosition3K == j) {
                j += 2;
            }
        }
    } else {
        int j = 0;
        for (int i = 0; i < 5; i++, j++) {
            hand5[i] = hand7[j];
            if ((startPosition3K == j) || (startPosition1P == j)) {
                j++;
            }
        }
    }
}

-(void) getHand5HP7_4K:(int *)hand5 Hand7:(int *)hand7
{
    // 4Kがある場合は2枚飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if ((hand7[j] == hand7[j + 1])
            && (hand7[j] == hand7[j + 2])
            && (hand7[j] == hand7[j + 3]) ) {
            j = j + 2;
        }
    }
}

/*
 * 3つ目〜5つ目の要素でパターン分け
 * パターン1 AA A22 33　3つ目と7つ目を飛ばす
 * パターン2 AA 222 33　3つ目と7つ目を飛ばす
 * パターン3 AA 223 33　6つ目と7つ目を飛ばす
 *
 */
-(void) getHand5HP7_3K2P:(int *)hand5 Hand7:(int *)hand7
{
    // パターン3のとき
    if ((hand7[2] == hand7[3]) && (hand7[3] < hand7[4])) {
        for (int i = 0; i < 5; i++) {
            hand5[i] = hand7[i];
        }
    } else { // パターン1, 2
        hand5[0] = hand7[0];
        hand5[1] = hand7[1];
        hand5[2] = hand7[3];
        hand5[3] = hand7[4];
        hand5[4] = hand7[5];
    }
}

-(void) getHand5HP7_3K3K:(int *)hand5 Hand7:(int *)hand7
{
    // 3Kがある場合は1枚飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if ((hand7[j] == hand7[j + 1])
            && (hand7[j] == hand7[j + 2])) {
            j++;
        }
    }
}

-(void) getHand5HP7_4K1P:(int *)hand5 Hand7:(int *)hand7
{
    // 4Kがある場合は2枚飛ばす
    int j = 0;
    for (int i = 0; i < 5; i++, j++) {
        hand5[i] = hand7[j];
        if ((hand7[j] == hand7[j + 1])
            && (hand7[j] == hand7[j + 2])
            && (hand7[j] == hand7[j + 3]) ) {
            j = j + 2;
        }
    }
}

/*
 * 必ず小さいrankから3つ 大きいrankから2つとるため、最初3つと後ろ2つを取得
 */
-(void) getHand5HP7_4K3K:(int *)hand5 Hand7:(int *)hand7
{
    hand5[0] = hand7[0];
    hand5[1] = hand7[1];
    hand5[2] = hand7[2];
    hand5[3] = hand7[5];
    hand5[4] = hand7[6];
}

- (NSInteger) judgeHP5_0P:(int *)handA Hand5B:(int *)handB
{
    for (int i = 4; i >= 0; i--) {
        if (handA[i] > handB[i]) {
            return 1;
        }
        if (handA[i] < handB[i]) {
            return 0;
        }
    }
    return 2;
}

- (NSInteger) judgeHP5_1P:(int *)handA Hand5B:(int *)handB
{
    // ペアとペアではないもので分ける
    int rank1PForA = 0;
    int handANoP[3] = {0};
    [self dividePairHP5_1P:handA RankPair:&rank1PForA Hand3:handANoP];
    
    int rank1PForB = 0;
    int handBNoP[3] = {0};
    [self dividePairHP5_1P:handB RankPair:&rank1PForB Hand3:handBNoP];
    
    // ペア比較で差があれば勝敗決定 なければペアではない部分を比較
    if (rank1PForA > rank1PForB) {
        return 1;
    } else if (rank1PForA < rank1PForB) {
        return 0;
    } else {
        for (int i = 2; i >= 0; i--) {
            if (handANoP[i] > handBNoP[i]) {
                return 1;
            }
            if (handANoP[i] < handBNoP[i]) {
                return 0;
            }
        }
    }
    return 2;
}

- (NSInteger) judgeHP5_2P:(int *)handA Hand5B:(int *)handB
{
    // ペアとペアではないもので分ける
    int rankTopPairForA = 0;
    int rankLowPairForA = 0;
    int rankKickerA = 0;
    [self dividePairHP5_2P:handA
               RankTopPair:&rankTopPairForA
               RankLowPair:&rankLowPairForA
                    Kicker:&rankKickerA];
    
    int rankTopPairForB = 0;
    int rankLowPairForB = 0;
    int rankKickerB = 0;
    
    [self dividePairHP5_2P:handB
               RankTopPair:&rankTopPairForB
               RankLowPair:&rankLowPairForB
                    Kicker:&rankKickerB];
    
    if (rankTopPairForA > rankTopPairForB) {
        return 1;
    }
    if (rankTopPairForA < rankTopPairForB) {
        return 0;
    }
    
    if (rankLowPairForA > rankLowPairForB) {
        return 1;
    }
    if (rankLowPairForA < rankLowPairForB) {
        return 0;
    }
    
    if (rankKickerA > rankKickerB) {
        return 1;
    }
    if (rankKickerA < rankKickerB) {
        return 0;
    }
    
    return 2;
}

- (NSInteger) judgeHP5_FH:(int *)handA Hand5B:(int *)handB
{
    // ペアと3Kに分ける
    int rank1PForA = 0;
    int rank3KForA = 0;
    [self dividePairHP5_FH:handA
                  RankPair:&rank1PForA
                RankThreeK:&rank3KForA];
    
    int rank1PForB = 0;
    int rank3KForB = 0;
    [self dividePairHP5_FH:handB
                  RankPair:&rank1PForB
                RankThreeK:&rank3KForB];
    
    if (rank3KForA > rank3KForB) {
        return 1;
    }
    if (rank3KForA < rank3KForB) {
        return 0;
    }
    return 2;
}

- (void) dividePairHP5_1P:(int *)hand5
                 RankPair:(int *)rankPair
                    Hand3:(int *)hand3
{
    int j = 0;
    for (int i = 0; i < 4; i++) {
        if (hand5[i] == hand5[i + 1]) {
            *rankPair = hand5[i];
        } else {
            hand3[j] = hand5[i];
            j++;
        }
    }
    // 最後の要素が比較されないので手動チェック
    if (*rankPair != hand5[4]) {
        hand3[2] = hand5[4];
    }
}

- (void) dividePairHP5_2P:(int *)hand5
              RankTopPair:(int *)rankTopPair
              RankLowPair:(int *)rankLowPair
                   Kicker:(int *)kicker
{
    *rankTopPair = 0;
    *rankLowPair = 0;
    *kicker = 0;
    for (int i = 0; i < 4; i++) {
        if (hand5[i] == hand5[i + 1]) {
            if (*rankLowPair == 0) {
                *rankLowPair = hand5[i];
            } else {
                *rankTopPair = hand5[i];
            }
            i++;
        } else {
            *kicker = hand5[i];
        }
    }
    // 最後の要素が比較されないので手動チェック
    if (*kicker == 0) {
        *kicker = hand5[4];
    }
}

- (void) dividePairHP5_FH:(int *)hand5
                 RankPair:(int *)rankPair
               RankThreeK:(int *)rank3K
{
    if (hand5[2] == hand5[0]) {
        *rankPair = hand5[4];
        *rank3K = hand5[0];
    } else {
        *rankPair = hand5[0];
        *rank3K = hand5[4];
    }
}

// ここから2枚用
- (NSInteger) countPair_HP2:(int *)hand
{
    if (hand[0] == hand[1]) {
        return 1;
    } else {
        return 0;
    }
}


// ここから3枚用
- (NSInteger) countPair_HP3:(int *)hand
{
    if ((hand[0] == hand[1]) || (hand[1] == hand[2])) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger) count3K_HP3:(int *)hand
{
    if ((hand[0] == hand[1]) && (hand[1] == hand[2])) {
        return 1;
    } else {
        return 0;
    }
}

- (void) dividePairHP3_1P:(int *)hand3
                 RankPair:(int *)rankPair
                   Kicker:(int *)kicker
{
    for (int i = 0; i < 2; i++) {
        if (hand3[i] == hand3[i + 1]) {
            *rankPair = hand3[i];
        } else {
            *kicker = hand3[i];
        }
    }
    // 最後の要素が比較されないので手動チェック
    if (*rankPair != hand3[2]) {
        *kicker = hand3[2];
    }
}

- (NSInteger) judgeHP3_1P:(int *)handA Hand3B:(int *)handB
{
    // ペアとペアではないもので分ける
    int rank1PForA = 0;
    int kickerA = 0;
    [self dividePairHP3_1P:handA RankPair:&rank1PForA Kicker:&kickerA];
    
    int rank1PForB = 0;
    int kickerB = 0;
    [self dividePairHP3_1P:handB RankPair:&rank1PForB Kicker:&kickerB];
    
    // ペア比較で差があれば勝敗決定 なければペアではない部分を比較
    if (rank1PForA > rank1PForB) {
        return 1;
    } else if (rank1PForA < rank1PForB) {
        return 0;
    } else {
        if (kickerA > kickerB) {
            return 1;
        }
        if (kickerA < kickerB) {
            return 0;
        }
    }
    return 2;
}

// ここから4枚用
- (NSInteger) countPair_HP4:(int *)hand
{
    NSInteger pairCounter = 0;
    NSInteger threeKCounter = [self count3K_HP4:hand];
    NSInteger fourKCounter = [self count4K_HP4:hand];
    for (int i = 0; i < 4; i++) {
        if (hand[i] == hand[i + 1]) {
            pairCounter++;
        }
    }
    return (pairCounter - (threeKCounter * 2) - (fourKCounter * 3));
}

- (NSInteger) count3K_HP4:(int *)hand
{
    NSInteger threeKCounter = 0;
    NSInteger fourKCounter = [self count4K_HP4:hand];
    for (int i = 0; i < 2; i++) {
        if ( (hand[i] == hand[i + 1]) && (hand[i] == hand[i + 2])) {
            threeKCounter++;
        }
    }
    return threeKCounter - (fourKCounter * 2);
}

- (NSInteger) count4K_HP4:(int *)hand
{
    if ((hand[0] == hand[1]) && (hand[0] == hand[2]) && (hand[0] == hand[3])) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger) judgeHP4_0P:(int *)handA Hand4B:(int *)handB
{
    for (int i = 3; i >= 0; i--) {
        if (handA[i] > handB[i]) {
            return 1;
        }
        if (handA[i] < handB[i]) {
            return 0;
        }
    }
    return 2;
}

- (NSInteger) judgeHP4_1P:(int *)handA Hand4B:(int *)handB
{
    // ペアとペアではないもので分ける
    int rank1PForA = 0;
    int handANoP[2] = {0};
    [self dividePairHP4_1P:handA RankPair:&rank1PForA Hand2:handANoP];
    
    int rank1PForB = 0;
    int handBNoP[2] = {0};
    [self dividePairHP4_1P:handB RankPair:&rank1PForB Hand2:handBNoP];
    
    // ペア比較で差があれば勝敗決定 なければペアではない部分を比較
    if (rank1PForA > rank1PForB) {
        return 1;
    } else if (rank1PForA < rank1PForB) {
        return 0;
    } else {
        for (int i = 1; i >= 0; i--) {
            if (handANoP[i] > handBNoP[i]) {
                return 1;
            }
            if (handANoP[i] < handBNoP[i]) {
                return 0;
            }
        }
    }
    return 2;
}

- (NSInteger) judgeHP4_2P:(int *)handA Hand4B:(int *)handB
{
    // 2244 とか 55JJのようになっているので、上位のカードから比較
    if (handA[2] > handB[2]) {
        return 1;
    }
    if (handA[2] < handB[2]) {
        return 0;
    }
    
    if (handA[0] > handB[0]) {
        return 1;
    }
    if (handA[0] < handB[0]) {
        return 0;
    }
    
    return 2;
}

- (NSInteger) judgeHP4_3K:(int *)handA Hand4B:(int *)handB
{
    // 3Kとkickerに分ける
    int rank3KForA = 0;
    int kickerA = 0;
    [self dividePairHP4_3K:handA
                RankThreeK:&rank3KForA
                    Kicker:&kickerA];
    
    int rank3KForB = 0;
    int kickerB = 0;
    [self dividePairHP4_3K:handB
                RankThreeK:&rank3KForB
                    Kicker:&kickerB];
    
    if (rank3KForA > rank3KForB) {
        return 1;
    }
    if (rank3KForA < rank3KForB) {
        return 0;
    }
    
    if (kickerA > kickerB) {
        return 1;
    }
    if (kickerA < kickerB) {
        return 0;
    }
    return 2;
}

- (void) dividePairHP4_1P:(int *)hand4
                 RankPair:(int *)rankPair
                    Hand2:(int *)hand2
{
    int j = 0;
    for (int i = 0; i < 3; i++) {
        if (hand4[i] == hand4[i + 1]) {
            *rankPair = hand4[i];
        } else {
            hand2[j] = hand4[i];
            j++;
        }
    }
    // 最後の要素が比較されないので手動チェック
    if (*rankPair != hand4[3]) {
        hand2[1] = hand4[3];
    }
}

- (void) dividePairHP4_3K:(int *)hand4
               RankThreeK:(int *)rankThreeK
                   Kicker:(int *)kicker
{
    for (int i = 0; i < 1; i++) {
        if ((hand4[i] == hand4[i + 1]) && (hand4[i] == hand4[i + 2])) {
            *rankThreeK = hand4[i];
        } else {
            *kicker = hand4[i];
        }
    }
    // 最後の要素が比較されないので手動チェック
    if (*rankThreeK != hand4[3]) {
        *kicker = hand4[3];
    }
}

@end
