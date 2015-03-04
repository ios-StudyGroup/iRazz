//
//  RazzHand.h
//  iRazz
//
//  Created by Ryou Inoue on 9/4/14.
//  Copyright (c) 2014 cat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface RazzHand : NSObject

#define HAND_SIZE 7 /* 手札は最大7枚 */

typedef NS_ENUM(NSUInteger, HP7) { /* HandPattern7 */
    HP7_0P,     // HP5_0P group
    HP7_1P,     // HP5_0P group
    HP7_2P,     // HP5_0P group
    HP7_3K,     // HP5_0P group
    HP7_3P,     // HP5_1P group
    HP7_3K1P,   // HP5_1P group
    HP7_4K,     // HP5_1P group
    HP7_3K2P,   // HP5_2P group
    HP7_3K3K,   // HP5_2P group
    HP7_4K1P,   // HP5_2P group
    HP7_4K3K    // HP5_FH group
};

typedef NS_ENUM(NSUInteger, HP5) { /* HandPattern5 */
    HP5_0P,
    HP5_1P,
    HP5_2P,
    HP5_FH,
};

typedef NS_ENUM(NSUInteger, HP4) { /* HandPattern4 */
    HP4_0P,
    HP4_1P,
    HP4_2P,
    HP4_3K,
    HP4_4K,
};

- (NSInteger) judgeHandA:(NSArray *)handA HandB:(NSArray *)handB;
- (NSInteger) checkHP7:(int *)hand;
- (NSInteger) checkHP5:(int *)hand;
- (NSInteger) checkHP4:(int *)hand;

@end
