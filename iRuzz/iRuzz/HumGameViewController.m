//
//  HumGameViewController.m
//  iRazz
//
//  Created by cat on 2015/03/01.
//  Copyright (c) 2015年 cat. All rights reserved.
//

#import "HumGameViewController.h"
#import "SessionHelperSingleton.h"

@interface HumGameViewController ()<UITextFieldDelegate, SessionHelperDelegate>

@property (readwrite) GAMESTATE state;

@end



@implementation HumGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //　通信後に実行されるdelegateメソッドのオブジェクトを自身に変更
    [SessionHelperSingleton sharedManager].delegate = self;
    
    // labelのカドを丸くする
    [self setLabel:self.a_card1];
    [self setLabel:self.a_card2];
    [self setLabel:self.a_card3];
    [self setLabel:self.a_card4];
    [self setLabel:self.a_card5];
    [self setLabel:self.a_card6];
    [self setLabel:self.a_card7];
    [self setLabel:self.y_card1];
    [self setLabel:self.y_card2];
    [self setLabel:self.y_card3];
    [self setLabel:self.y_card4];
    [self setLabel:self.y_card5];
    [self setLabel:self.y_card6];
    [self setLabel:self.y_card7];
    self.state = PLAYING;
    
    if (self.isHost == YES) {
        self.a_card1.text = @"";
        self.a_card2.text = @"";
        self.a_card3.text = [self.deck getCard:4].displayString;
        self.a_card4.text = [self.deck getCard:6].displayString;
        self.a_card5.text = [self.deck getCard:8].displayString;
        self.a_card6.text = [self.deck getCard:10].displayString;
        self.a_card7.text = @"";

        self.y_card1.text = [self.deck getCard:1].displayString;
        self.y_card2.text = [self.deck getCard:3].displayString;
        self.y_card3.text = [self.deck getCard:5].displayString;
        self.y_card4.text = [self.deck getCard:7].displayString;
        self.y_card5.text = [self.deck getCard:9].displayString;
        self.y_card6.text = [self.deck getCard:11].displayString;
        self.y_card7.text = [self.deck getCard:13].displayString;
        
        self.a_card4.hidden = YES;
        self.a_card5.hidden = YES;
        self.a_card6.hidden = YES;
        self.a_card7.hidden = YES;
        self.y_card4.hidden = YES;
        self.y_card5.hidden = YES;
        self.y_card6.hidden = YES;
        self.y_card7.hidden = YES;
        
        self.pot.text = @"10";
        Card *a_card3 = [self.deck getCard:4];
        Card *y_card3 = [self.deck getCard:5];
        if ([a_card3 judgeRazzCardA:a_card3 CardB:y_card3] == 0) {
            self.y_bet.text = @"5";
            self.a_bet.text = @"0";
        }
        else {
            self.y_bet.text = @"0";
            self.a_bet.text = @"5";
        }
    }
    else {
        self.a_card1.text = @"";
        self.a_card2.text = @"";
        self.a_card3.text = [self.deck getCard:5].displayString;
        self.a_card4.text = [self.deck getCard:7].displayString;
        self.a_card5.text = [self.deck getCard:9].displayString;
        self.a_card6.text = [self.deck getCard:11].displayString;
        self.a_card7.text = @"";
        
        self.y_card1.text = [self.deck getCard:0].displayString;
        self.y_card2.text = [self.deck getCard:2].displayString;
        self.y_card3.text = [self.deck getCard:4].displayString;
        self.y_card4.text = [self.deck getCard:6].displayString;
        self.y_card5.text = [self.deck getCard:8].displayString;
        self.y_card6.text = [self.deck getCard:10].displayString;
        self.y_card7.text = [self.deck getCard:12].displayString;
        
        self.a_card4.hidden = YES;
        self.a_card5.hidden = YES;
        self.a_card6.hidden = YES;
        self.a_card7.hidden = YES;
        self.y_card4.hidden = YES;
        self.y_card5.hidden = YES;
        self.y_card6.hidden = YES;
        self.y_card7.hidden = YES;
        
        self.pot.text = @"10";
        Card *a_card3 = [self.deck getCard:5];
        Card *y_card3 = [self.deck getCard:4];
        if ([a_card3 judgeRazzCardA:a_card3 CardB:y_card3] == 0) {
            self.y_bet.text = @"5";
            self.a_bet.text = @"0";
        }
        else {
            self.y_bet.text = @"0";
            self.a_bet.text = @"5";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)raise:(id)sender
{
    if (self.state == END) { /* 最後まで盤面が進んでいれば無効化 */
        return;
    }
    
    [sender setEnabled:NO];
    
    if (self.y_card5.hidden == YES) { /* 4th street までは raise額5 */
        NSInteger abetPrize = self.a_bet.text.integerValue;
        NSInteger ybetPrize = abetPrize + 5;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        if (abetPrize != ybetPrize) { //一致しない場合はコール
            abetPrize = ybetPrize;
        }
        self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    } else { /* 4th street 以降は raise額10 */
        NSInteger abetPrize = self.a_bet.text.integerValue;
        NSInteger ybetPrize = abetPrize + 10;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        if (abetPrize != ybetPrize) { //一致しない場合はコール
            abetPrize = ybetPrize;
        }
        self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
    [self commitPot];
    [self loadNextCard];

    [sender setEnabled:YES];
}

- (IBAction)call:(id)sender
{
    if (self.state == END) { /* 最後まで盤面が進んでいれば無効化 */
        return;
    }
    [sender setEnabled:NO];
    
    NSInteger ybetPrize = self.y_bet.text.integerValue;
    NSInteger abetPrize = self.a_bet.text.integerValue;
    if (abetPrize > ybetPrize) { //一致しない場合は合わせる(ブリングインの時は、一致しないけど、合わせない）
        ybetPrize = abetPrize;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        [self commitPot];
        [self loadNextCard];
    }
    
    //とりあえずcallを投げてみる
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton sendMessage:@"call"];

    [sender setEnabled:YES];
}

- (IBAction)fold:(id)sender
{
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton sendMessage:@"fold"];

    [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
}

- (void) setLabel:(UILabel *)label
{
    [[label layer] setCornerRadius:10.0];
    [label setClipsToBounds:YES];
    [[label layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[label layer] setBorderWidth:1.0];
}

- (void) loadNextCard
{
    if (self.y_card4.hidden == YES) {
        self.y_card4.hidden = NO;
        self.a_card4.hidden = NO;
        return;
    };
    if (self.y_card5.hidden == YES) {
        self.y_card5.hidden = NO;
        self.a_card5.hidden = NO;
        return;
    };
    if (self.y_card6.hidden == YES) {
        self.y_card6.hidden = NO;
        self.a_card6.hidden = NO;
        return;
    };
    if (self.y_card7.hidden == YES) {
        self.y_card7.hidden = NO;
        self.a_card7.hidden = NO;
        return;
    };
    if (self.y_card7.hidden == NO) { /* showdown */
        NSArray *handA;
        NSArray *handY;
        
        if (self.isHost == YES) {
            self.a_card1.text = [self.deck getCard:0].displayString;
            self.a_card2.text = [self.deck getCard:2].displayString;
            self.a_card7.text = [self.deck getCard:12].displayString;
            handA = [NSArray arrayWithObjects:[self.deck getCard:0], [self.deck getCard:2], [self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], [self.deck getCard:10], [self.deck getCard:12], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:1], [self.deck getCard:3], [self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], [self.deck getCard:11], [self.deck getCard:13], nil];
        }
        else {
            self.a_card1.text = [self.deck getCard:1].displayString;
            self.a_card2.text = [self.deck getCard:3].displayString;
            self.a_card7.text = [self.deck getCard:13].displayString;
            handA = [NSArray arrayWithObjects:[self.deck getCard:1], [self.deck getCard:3], [self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], [self.deck getCard:11], [self.deck getCard:13], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:0], [self.deck getCard:2], [self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], [self.deck getCard:10], [self.deck getCard:12], nil];
        }
        self.a_card1.backgroundColor = [UIColor whiteColor];
        self.a_card2.backgroundColor = [UIColor whiteColor];
        self.a_card7.backgroundColor = [UIColor whiteColor];
        
        RazzHand *russHand = [[RazzHand alloc] init];
        NSInteger ret = [russHand judgeHandA:handA HandB:handY];
        
        // for debug
        NSString *alertMessage;
        if (ret == 0) {
            alertMessage = @"You Lose!";
        } else if (ret == 1) {
            alertMessage = @"You Win!";
        } else {
            alertMessage = @"Draw";
        }
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:@"Result"
         message:alertMessage
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil
         ];
        [alert show];
        self.state = END; /* ゲーム終了状態へ遷移 */

        return;
    };
}


- (void) commitPot
{
    NSInteger potPrize = self.pot.text.integerValue;
    potPrize = potPrize + self.y_bet.text.integerValue + self.a_bet.text.integerValue;
    self.pot.text = [NSString stringWithFormat:@"%ld", (long)potPrize];
    self.y_bet.text = @"0";
    self.a_bet.text = @"0";
}

/*
 * @retval    0     aのハンドが強い ex a=2 b=5
 * @retval    1     bのハンドが強い ex a=T b=A
 * @retval    2     引き分け(とりあえずなし）
*/
- (NSInteger) judgeCurrentHand
{
    if (self.y_card4.hidden == YES) {
        Card *a_card3;
        Card *y_card3;
        
        if (self.isHost == YES) {
            a_card3 = [self.deck getCard:4];
            y_card3 = [self.deck getCard:5];
        } else {
            a_card3 = [self.deck getCard:5];
            y_card3 = [self.deck getCard:4];
        }
        return [a_card3 judgeRazzCardA:a_card3 CardB:y_card3];
    }
    if (self.y_card5.hidden == YES) {

        NSArray *handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], nil];
        NSArray *handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], nil];
    
        RazzHand *russHand = [[RazzHand alloc] init];
        return [russHand judgeHandA:handA HandB:handY];
    }
    if (self.y_card6.hidden == YES) {
        NSArray *handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], nil];
        NSArray *handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], nil];
        
        RazzHand *russHand = [[RazzHand alloc] init];
        return [russHand judgeHandA:handA HandB:handY];
    }
    if (self.y_card7.hidden == YES) {
        NSArray *handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], [self.deck getCard:11], nil];
        NSArray *handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], [self.deck getCard:10], nil];
        
        RazzHand *russHand = [[RazzHand alloc] init];
        return [russHand judgeHandA:handA HandB:handY];
    }
    return -1;
}

# pragma mark - SessionHelperDelegate methods
- (void) receivedMessage:(NSString *)message
{
    if ([message isEqualToString:@"call"] == YES) {
        [self receivedCall];
    } else if ([message isEqualToString:@"raise"] == YES) {
        [self receivedRaise];
    } else if ([message isEqualToString:@"fold"] == YES) {
        [self receivedFold];
    }
}

- (void) receivedCall {
    NSLog(@"%s", __func__);
    NSInteger ybetPrize = self.y_bet.text.integerValue;
    NSInteger abetPrize = self.a_bet.text.integerValue;
    if (abetPrize > ybetPrize) { //ブリングインケース
        // なにもしなくていい
        NSLog(@"bring in");
    } else { // 4th以降の場合
        if (([self judgeCurrentHand] == 0)      // 自分から動作開始の場合
            || (self.y_card4.hidden == YES)) {  // ブリングインで、コールで帰ってきた時
            NSLog(@"goto next");
            abetPrize = ybetPrize;
            // メインスレッドで処理を実行
            dispatch_async(dispatch_get_main_queue(), ^{
                self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
                [self commitPot];
                [self loadNextCard];
            });
        } else { // 相手から動作開始の場合
            // 入力をするようにしましょう
            NSLog(@"wait input");
        }
    }
}

- (void) receivedRaise {
    NSLog(@"%s", __func__);
}

- (void) receivedFold {
    [self dismissViewControllerAnimated:NO completion:nil]; /* Close */

    NSLog(@"%s", __func__);
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"Result"
     message:@"You Win!"
     delegate:nil
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil
     ];
    [alert show];
    self.state = END; /* ゲーム終了状態へ遷移 */
}

@end
