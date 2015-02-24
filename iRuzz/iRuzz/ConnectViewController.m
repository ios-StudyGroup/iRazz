//
//  ConnectViewController.m
//  iRazz
//
//  Created by Ryou Inoue on 2015/02/24.
//  Copyright (c) 2015年 cat. All rights reserved.
//
/**
 @todo
 
 MCBrowserViewControllerを使って接続した方がいいかも
 MCBrowserViewControllerを使うと独自処理ができないため、この方法を考えた
 でも、この方法だとViewの表示に時間がかかってしまう（原因は不明）
 
 */
#import "ConnectViewController.h"
#import "SessionHelperSingleton.h"
#import "GameViewController.h"
#import "Deck.h"

@interface ConnectViewController ()<UITextFieldDelegate, SessionHelperDelegate>

@property Deck* deck;
@property BOOL isHost;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;


@property (weak, nonatomic) IBOutlet UIButton *hostButton;
@property (weak, nonatomic) IBOutlet UIButton *clientButton;

@property (weak, nonatomic) IBOutlet UIButton *gameStartButton;


- (IBAction)hostButtonClick:(id)sender;
- (IBAction)clientButtonClick:(id)sender;
- (IBAction)gameStartButtonClick:(id)sender;


@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [SessionHelperSingleton sharedManager].delegate = self;
    [self.gameStartButton setTitle:@"未接続" forState:UIControlStateNormal];
    self.gameStartButton.enabled = NO;
    
    
    // UITextFieldDelegateの設定
    self.displayNameTextField.delegate = self;
    // 「改行（Return）」キーの設定
    self.displayNameTextField.returnKeyType = UIReturnKeyDone;
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hostButtonClick:(id)sender
{
    NSLog(@"%s", __func__);
    
    if ([self checkDisplayName:self.displayNameTextField.text] != YES){
        return;
    }
    
    //    self.hostButton.enabled = NO;
    //    self.clientButton.enabled = NO;
    
    self.isHost = YES;
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton startBrowsiongWithDisplayName:self.displayNameTextField.text];
    [self.gameStartButton setTitle:@"接続待ち" forState:UIControlStateNormal];
    
}
- (IBAction)clientButtonClick:(id)sender
{
    NSLog(@"%s", __func__);
    
    if ([self checkDisplayName:self.displayNameTextField.text] != YES){
        return;
    }
    
    //    self.hostButton.enabled = NO;
    //    self.clientButton.enabled = NO;
    
    self.isHost = NO;
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton startAdvertisingWithDisplayName:self.displayNameTextField.text];
    [self.gameStartButton setTitle:@"接続待ち" forState:UIControlStateNormal];
    
    
}

- (IBAction)gameStartButtonClick:(id)sender
{
    [self performSegueWithIdentifier:@"PushGameStart" sender:self];
    
}

-(BOOL)checkDisplayName:(NSString *)displayName
{
    if ([displayName length] == 0){
        return NO;
    }else{
        return YES;
    }
}


# pragma mark - UITextFieldDelegate methods
// キーボードのDoneをタップすると、キーボードを閉じるように
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSLog(@"%s", __func__);
    
    [self.displayNameTextField resignFirstResponder];
    return YES;
}




# pragma mark - SessionHelperDelegate methods
-(void)sessionConnected{
    NSLog(@"%s", __func__);
    
    self.hostButton.enabled = YES;
    self.clientButton.enabled = YES;
    
    [self.gameStartButton setTitle:@"ゲーム開始" forState:UIControlStateNormal];
    self.gameStartButton.enabled = YES;
    
    if (self.isHost == YES){
        // 適当に配列を作る
        // カードを生成
        self.deck = [[Deck alloc] init];
        
        [[SessionHelperSingleton sharedManager] sendDeck:self.deck];
    }
    
    
}
-(void)receivedDeck:(NSArray *)deck
{
    NSLog(@"%s",__func__);
    
    self.hostButton.enabled = YES;
    self.clientButton.enabled = YES;
    
    [self.gameStartButton setTitle:@"ゲーム開始" forState:UIControlStateNormal];
    self.gameStartButton.enabled = YES;
    self.deck = [deck mutableCopy];
    
}


#pragma mark - Navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s", __func__);
    NSLog(@"identifier is %@",segue.identifier);
    
    if ([segue.identifier isEqualToString:@"PushGameStart"]) {
        GameViewController *viewController = segue.destinationViewController;
        viewController.deck = self.deck;
        viewController.isHost = self.isHost;
    }
}




@end