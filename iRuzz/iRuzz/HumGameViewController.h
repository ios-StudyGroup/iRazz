//
//  HumGameViewController.h
//  iRazz
//
//  Created by cat on 2015/03/01.
//  Copyright (c) 2014年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Deck.h"
#import "RazzHand.h"

@interface HumGameViewController : UIViewController

@property (strong, nonatomic) Deck *deck;
@property BOOL isHost;
@property (weak, nonatomic) IBOutlet UILabel *a_card1;
@property (weak, nonatomic) IBOutlet UILabel *a_card2;
@property (weak, nonatomic) IBOutlet UILabel *a_card3;
@property (weak, nonatomic) IBOutlet UILabel *a_card4;
@property (weak, nonatomic) IBOutlet UILabel *a_card5;
@property (weak, nonatomic) IBOutlet UILabel *a_card6;
@property (weak, nonatomic) IBOutlet UILabel *a_card7;
@property (weak, nonatomic) IBOutlet UILabel *y_card1;
@property (weak, nonatomic) IBOutlet UILabel *y_card2;
@property (weak, nonatomic) IBOutlet UILabel *y_card3;
@property (weak, nonatomic) IBOutlet UILabel *y_card4;
@property (weak, nonatomic) IBOutlet UILabel *y_card5;
@property (weak, nonatomic) IBOutlet UILabel *y_card6;
@property (weak, nonatomic) IBOutlet UILabel *y_card7;

@property (weak, nonatomic) IBOutlet UILabel *pot;
@property (weak, nonatomic) IBOutlet UILabel *a_bet;
@property (weak, nonatomic) IBOutlet UILabel *y_bet;

- (IBAction)raise:(id)sender;
- (IBAction)call:(id)sender;
- (IBAction)fold:(id)sender;



@end
