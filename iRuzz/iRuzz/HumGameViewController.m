//
//  HumGameViewController.m
//  iRazz
//
//  Created by cat on 2015/03/01.
//  Copyright (c) 2015年 cat. All rights reserved.
//

#import "HumGameViewController.h"
#import "SessionHelperSingleton.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, GAMESTATE) {
    PLAYING,
    END,
};

#define MAXRAISECOUNT 1

@interface HumGameViewController ()<UITextFieldDelegate, SessionHelperDelegate>

@property (readwrite) GAMESTATE state;
@property BOOL isChangeView; // 画面遷移をしてもいいかのフラグ(対戦相手がFoldでゲームを終了->アラート表示中に、再度、対戦をしようとした時はViewを元に戻さない)
@property NSInteger raiseCount;

@end



@implementation HumGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"%s",__func__);

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"%s",__func__);

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.logLabel.hidden = YES;


}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    //　通信後に実行されるdelegateメソッドのオブジェクトを自身に変更
    [SessionHelperSingleton sharedManager].delegate = self;
    
    
    [self initialStatus];
}


- (void)initialStatus
{
    
    self.logLabel.hidden = YES;

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
    self.a_card1.backgroundColor = [UIColor blueColor];
    self.a_card2.backgroundColor = [UIColor blueColor];
    self.a_card7.backgroundColor = [UIColor blueColor];

    
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
    
    self.isChangeView = YES;
    
    [self.raiseButton setEnabled:NO];
    [self.callButton setEnabled:NO];
    [self.foldButton setEnabled:NO];
    NSInteger judge = [self judgeCurrentHand];
    if (judge == 0) { // 自分が弱い場合
        [self.raiseButton setEnabled:YES];
        [self.callButton setEnabled:YES];
        [self.foldButton setEnabled:YES];
    } else {
        [self.raiseButton setEnabled:NO];
        [self.callButton setEnabled:NO];
        [self.foldButton setEnabled:NO];
    }
    
    self.raiseCount = 0;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"%s",__func__);

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
    NSLog(@"%s",__func__);
    if ([self isActiveSession] == NO){
        // 前画面に戻る
        [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
        self.state = END; /* ゲーム終了状態へ遷移 */
    }


    if ( (self.raiseCount >= MAXRAISECOUNT) || /* レイズカウントが最大なら無効化 */
         (self.state == END) ) { /* 最後まで盤面が進んでいれば無効化 */
        return;
    }
    
    [self.raiseButton setEnabled:NO];
    [self.callButton setEnabled:NO];
    [self.foldButton setEnabled:NO];
    self.raiseCount++;
    
    //とりあえずraiseを投げてみる
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    if ([sessionHelperSingleton sendMessage:@"raise"] == NO){
        // アラートを表示
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"Raiseに失敗しました" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
        
    }
    
    if (self.y_card5.hidden == YES) { /* 4th street までは raise額5 */
        NSInteger abetPrize = self.a_bet.text.integerValue;
        NSInteger ybetPrize = abetPrize + 5;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//        if (abetPrize != ybetPrize) { //一致しない場合はコール
//            abetPrize = ybetPrize;
//        }
//        self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    } else { /* 4th street 以降は raise額10 */
        NSInteger abetPrize = self.a_bet.text.integerValue;
        NSInteger ybetPrize = abetPrize + 10;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
//        if (abetPrize != ybetPrize) { //一致しない場合はコール
//            abetPrize = ybetPrize;
//        }
//        self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}

- (IBAction)call:(id)sender
{
    NSLog(@"%s",__func__);
    if ([self isActiveSession] == NO){
        // 前画面に戻る
        [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
        self.state = END; /* ゲーム終了状態へ遷移 */
    }
    

    if (self.state == END) { /* 最後まで盤面が進んでいれば無効化 */
        return;
    }
    [self.raiseButton setEnabled:NO];
    [self.callButton setEnabled:NO];
    [self.foldButton setEnabled:NO];

    
    //とりあえずcallを投げてみる
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    if ([sessionHelperSingleton sendMessage:@"call"] == NO){
        // アラートを表示
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"Callに失敗しました" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
        
    }

    
    NSInteger ybetPrize = self.y_bet.text.integerValue;
    NSInteger abetPrize = self.a_bet.text.integerValue;
    if (abetPrize > ybetPrize) { //一致しない場合は合わせる
        ybetPrize = abetPrize;
        self.y_bet.text = [NSString stringWithFormat:@"%ld", (long)ybetPrize];
        [self commitPot];
        [self loadNextCard];
    } else if (abetPrize < ybetPrize) {
        // ブリングインのときなので、することはない。
    } else { // 0枚でコールする場合
        NSInteger judge = [self judgeCurrentHand];
        if ((judge == 0) ||
            ((judge == 2) && (self.isHost == YES))) { // 自分が弱いか、引き分けで相手からの場合
            [self commitPot];
            [self loadNextCard];
        }
    }
}

- (IBAction)fold:(id)sender
{
    NSLog(@"%s",__func__);
    if ([self isActiveSession] == NO){
        // 前画面に戻る
        [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
        self.state = END; /* ゲーム終了状態へ遷移 */
    }

    

    // 次のゲーム or ゲーム終了のダイアログを表示
    UIAlertController *alertController
    = [UIAlertController alertControllerWithTitle:@"Fold"
                                          message:@"ゲームを続けますか？"
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"次のゲーム" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 続ける場合は、Deckを作成し送信する
        SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
        [sessionHelperSingleton sendMessage:@"nextGame"];
        
        self.deck = [[Deck alloc] init];
        [self initialStatus];
        
        [[SessionHelperSingleton sharedManager] sendDeck:[NSKeyedArchiver archivedDataWithRootObject:self.deck]];

    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"対戦終了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 対戦を終了する場合は、quitメッセージを送信し、前の画面に遷移
        SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
        [sessionHelperSingleton sendMessage:@"quit"];
        
        [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
        self.state = END; /* ゲーム終了状態へ遷移 */
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"閉じる" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    // iPad用の設定
    alertController.popoverPresentationController.sourceView = self.view;
    alertController.popoverPresentationController.sourceRect = CGRectMake(100.0, 100.0, 20.0, 20.0);
    
    // 表示
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void) setLabel:(UILabel *)label
{
    NSLog(@"%s",__func__);

    [[label layer] setCornerRadius:10.0];
    [label setClipsToBounds:YES];
    [[label layer] setBorderColor:[[UIColor blueColor] CGColor]];
    [[label layer] setBorderWidth:1.0];
}

/*
 * 自分のターンか判断し、自分のターンであれば、ボタンを有効化。
 */
- (void) judgeTurn
{
    NSInteger judge = [self judgeCurrentHand];
    if ((judge == 1) ||
        ((judge == 2) && (self.isHost == NO))) { // 自分が強いか、引き分けで自分からの場合
        [self.raiseButton setEnabled:YES];
        [self.callButton setEnabled:YES];
        [self.foldButton setEnabled:YES];
        NSLog(@"my turn");
    }
}

- (void) loadNextCard
{
    NSLog(@"%s",__func__);
    [self.raiseButton setEnabled:NO];
    [self.callButton setEnabled:NO];
    [self.foldButton setEnabled:NO];
    self.raiseCount = 0;

    if (self.y_card4.hidden == YES) {
        self.y_card4.hidden = NO;
        self.a_card4.hidden = NO;
        [self judgeTurn];
        return;
    };
    if (self.y_card5.hidden == YES) {
        self.y_card5.hidden = NO;
        self.a_card5.hidden = NO;
        [self judgeTurn];
        return;
    };
    if (self.y_card6.hidden == YES) {
        self.y_card6.hidden = NO;
        self.a_card6.hidden = NO;
        [self judgeTurn];
        return;
    };
    if (self.y_card7.hidden == YES) {
        self.y_card7.hidden = NO;
        self.a_card7.hidden = NO;
        [self judgeTurn];
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
        [self.foldButton setEnabled:YES];

        return;
    };
}


- (void) commitPot
{
    NSLog(@"%s",__func__);

    NSInteger potPrize = self.pot.text.integerValue;
    potPrize = potPrize + self.y_bet.text.integerValue + self.a_bet.text.integerValue;
    self.pot.text = [NSString stringWithFormat:@"%ld", (long)potPrize];
    self.y_bet.text = @"0";
    self.a_bet.text = @"0";
}

/*
 * @retval    0     aのハンドが強い ex a=2 b=5
 * @retval    1     yのハンドが強い ex a=T b=A
 * @retval    2     引き分け(とりあえずなし）
 * @retval   -1     エラー
*/
- (NSInteger) judgeCurrentHand
{
    NSLog(@"%s",__func__);

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

    NSArray *handA = nil;
    NSArray *handY = nil;
    
    if (self.y_card5.hidden == YES) {
        if (self.isHost == YES) {
            handA = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], nil];
        } else {
            handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], nil];
        }
    } else if (self.y_card6.hidden == YES) {
        if (self.isHost == YES) {
            handA = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], nil];
        } else {
            handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], nil];
        }
    } else if ((self.y_card7.hidden == YES) ||
               ((self.y_card7.hidden == NO) && ([self.a_card7.text isEqualToString:@""] == YES))) {
        if (self.isHost == YES) {
            handA = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], [self.deck getCard:10], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], [self.deck getCard:11], nil];
        } else {
            handA = [NSArray arrayWithObjects:[self.deck getCard:5], [self.deck getCard:7], [self.deck getCard:9], [self.deck getCard:11], nil];
            handY = [NSArray arrayWithObjects:[self.deck getCard:4], [self.deck getCard:6], [self.deck getCard:8], [self.deck getCard:10], nil];
        }
    }
    RazzHand *russHand = [[RazzHand alloc] init];
    NSInteger result = [russHand judgeHandA:handA HandB:handY];
    NSLog(@"%s return judge = %ld", __func__, result);
    return result;
}

# pragma mark - SessionHelperDelegate methods
- (void) receivedMessage:(NSString *)message
{
    NSLog(@"%s",__func__);

    if ([message isEqualToString:@"call"] == YES) {
        [self receivedCall];
    } else if ([message isEqualToString:@"raise"] == YES) {
        [self receivedRaise];
    } else if ([message isEqualToString:@"fold"] == YES) {
        [self receivedFold];
    } else if ([message isEqualToString:@"nextGame"] == YES) {
        [self receivedNextGame];
    } else if ([message isEqualToString:@"quit"] == YES) {
        [self receivedQuit];
    }
}

-(void)receivedDeck:(Deck *)deck displayName:(NSString *)displayName
{
    NSLog(@"%s",__func__);
    self.deck = deck;
    
    
    [self initialStatus];
    self.isChangeView = NO;
}

-(void)foundPeer
{
    NSLog(@"%s",__func__);
    // 何もしない
    
}
-(void)lostPeer
{
    NSLog(@"%s",__func__);
    // 何もしない
}


-(void)didChangeState:(MCPeerID *)peerID state:(MCSessionState)state
{
    NSLog(@"%s", __func__);
    // 何もしない
}




- (void) receivedCall
{
    NSLog(@"%s", __func__);
    
    
    self.logLabel.text = @"Callされました";
    self.logLabel.hidden = NO;
    AVSpeechSynthesizer* speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    // AVSpeechUtteranceを読ませたい文字列で初期化する。
    NSString* speakingText = @"Callされました";
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
    
    // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
    [speechSynthesizer speakUtterance:utterance];
    
    [self performSelector:@selector(hiddenLogLabel) withObject:nil afterDelay:2.0];
    NSInteger ybetPrize = self.y_bet.text.integerValue;
    NSInteger abetPrize = self.a_bet.text.integerValue;
    if (self.y_card4.hidden == YES) { // 3rd street
        if (abetPrize > ybetPrize) { // ブリングインでコールで帰ってきた
            [self.raiseButton setEnabled:YES];
            [self.callButton setEnabled:YES];
            [self.foldButton setEnabled:YES];
        } else {
            abetPrize = ybetPrize;
            // メインスレッドで処理を実行
            dispatch_async(dispatch_get_main_queue(), ^{
                self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
                [self commitPot];
                [self loadNextCard];
            });
        }
    } else { // 4th以降の場合
        NSInteger judge = [self judgeCurrentHand];
        if ((judge == 1) ||
            ((judge == 2) && (self.isHost == NO))) { // 自分が強いか、引き分けで自分からの場合
            NSLog(@"goto next");
            abetPrize = ybetPrize;
            // メインスレッドで処理を実行
            dispatch_async(dispatch_get_main_queue(), ^{
                self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
                [self commitPot];
                [self loadNextCard];
            });
        } else { // 相手から動作開始の場合
            [self.raiseButton setEnabled:YES];
            [self.callButton setEnabled:YES];
            [self.foldButton setEnabled:YES];
        }
    }
}

- (void) receivedRaise
{
    NSLog(@"%s", __func__);
    self.logLabel.text = @"Raiseされました";
    [self performSelector:@selector(hiddenLogLabel) withObject:nil afterDelay:2.0];

    self.logLabel.hidden = NO;
    
    AVSpeechSynthesizer* speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    // AVSpeechUtteranceを読ませたい文字列で初期化する。
    NSString* speakingText = @"Raiseされました";
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:speakingText];
    [utterance setPitchMultiplier:0.75];
    
    // AVSpeechSynthesizerにAVSpeechUtteranceを設定して読んでもらう
    [speechSynthesizer speakUtterance:utterance];
    
    self.raiseCount++;
    
    NSInteger ybetPrize = self.y_bet.text.integerValue;
    NSInteger abetPrize = self.a_bet.text.integerValue;
    if (self.y_card5.hidden == YES) { /* 4th street までは raise額5 */
        if (abetPrize > ybetPrize) { // ブリングインのケースを考慮
            abetPrize = abetPrize + 5;
        } else {
            abetPrize = ybetPrize + 5;
        }
    } else { /* 4th street 以降は raise額10 */
        abetPrize = ybetPrize + 10;
    }
    self.a_bet.text = [NSString stringWithFormat:@"%ld", (long)abetPrize];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

    if (self.raiseCount < MAXRAISECOUNT) { // raiseできないときは無効のまま
        [self.raiseButton setEnabled:YES];
    }
    [self.callButton setEnabled:YES];
    [self.foldButton setEnabled:YES];
}

-(void)hiddenLogLabel
{
    NSLog(@"%s", __func__);
    self.logLabel.hidden = YES;
}

- (void) receivedFold {

    NSLog(@"%s",__func__);

    self.state = END; /* ゲーム終了状態へ遷移 */
}

- (void)receivedNextGame
{
    // 何もしない
    // nextGameが送られた後はDeckが送られてくるはず。そこで処理する
    NSLog(@"%s",__func__);
    
}

- (void)receivedQuit
{
    // ゲーム終了のアラートを表示し前の画面に遷移する
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通知" message:@"対戦相手がゲームを終了しました" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        if (self.isChangeView == YES){
            [self dismissViewControllerAnimated:NO completion:^{
                // 特になにもしない
            }]; /* Close */
            self.state = END; /* ゲーム終了状態へ遷移 */
        }else{
            // 再描画
            [self.view setNeedsDisplay];
            
        }
    }]];
    
    self.isChangeView = YES; //アラート表示中にDeckが送られてきたら、前の画面に戻らない

    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(BOOL)isActiveSession
{
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    if (sessionHelperSingleton.selectedPeerID == nil){
        // アラートを表示
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"接続がきれています" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

        
        return NO;
    }
    
    return YES;
}


@end
