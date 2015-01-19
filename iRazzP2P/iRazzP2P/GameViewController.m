//
//  GameViewController.m
//  iRazzP2P
//
//  Created by ryo on 2015/01/18.
//  Copyright (c) 2015年 ryo. All rights reserved.
//

#import "GameViewController.h"
#import "SessionHelperSingleton.h"

@interface GameViewController ()<SessionHelperDelegate>

@property (weak, nonatomic) IBOutlet UILabel *player_card1;
@property (weak, nonatomic) IBOutlet UILabel *player_card2;
@property (weak, nonatomic) IBOutlet UILabel *player_card3;
@property (weak, nonatomic) IBOutlet UILabel *player_card4;
@property (weak, nonatomic) IBOutlet UILabel *player_card5;
@property (weak, nonatomic) IBOutlet UILabel *player_card6;
@property (weak, nonatomic) IBOutlet UILabel *player_card7;


@property (weak, nonatomic) IBOutlet UILabel *opponent_card1;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card2;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card3;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card4;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card5;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card6;
@property (weak, nonatomic) IBOutlet UILabel *opponent_card7;


@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;
- (IBAction)dealButtonClick:(id)sender;
- (IBAction)cancelButtonClick:(id)sender;


@end

@implementation GameViewController

- (void)viewDidLoad {
    NSLog(@"%s", __func__);
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s", __func__);
    [SessionHelperSingleton sharedManager].delegate = self;
    [self startView];
}

- (IBAction)dealButtonClick:(id)sender {
    NSLog(@"%s", __func__);
    [self opencard];
    [[SessionHelperSingleton sharedManager] sendMessage:@"deal"];

}

- (IBAction)cancelButtonClick:(id)sender {
    NSLog(@"%s", __func__);

}


-(void)startView
{
    NSLog(@"%s", __func__);
    
    SessionHelperSingleton *sessionHelper = [SessionHelperSingleton sharedManager];
    self.playerNameLabel.text = sessionHelper.myPeerID.displayName;
    self.opponentNameLabel.text = sessionHelper.connectedPeerID.displayName;
    
    if (self.isHost == YES){
        self.opponent_card1.text = @"";
        self.opponent_card2.text = @"";
        self.opponent_card3.text = self.deck[4];
        self.opponent_card4.text = self.deck[6];
        self.opponent_card5.text = self.deck[8];
        self.opponent_card6.text = self.deck[10];
        self.opponent_card7.text = @"";
        
        self.player_card1.text = self.deck[1];
        self.player_card2.text = self.deck[3];
        self.player_card3.text = self.deck[5];
        self.player_card4.text = self.deck[7];
        self.player_card5.text = self.deck[9];
        self.player_card6.text = self.deck[11];
        self.player_card7.text = self.deck[13];
        
        self.opponent_card4.hidden = YES;
        self.opponent_card5.hidden = YES;
        self.opponent_card6.hidden = YES;
        self.opponent_card7.hidden = YES;
        self.player_card4.hidden = YES;
        self.player_card5.hidden = YES;
        self.player_card6.hidden = YES;
        self.player_card7.hidden = YES;
    }else{
        self.opponent_card1.text = @"";
        self.opponent_card2.text = @"";
        self.opponent_card3.text = self.deck[5];
        self.opponent_card4.text = self.deck[7];
        self.opponent_card5.text = self.deck[9];
        self.opponent_card6.text = self.deck[11];
        self.opponent_card7.text = @"";
        
        self.player_card1.text = self.deck[0];
        self.player_card2.text = self.deck[2];
        self.player_card3.text = self.deck[4];
        self.player_card4.text = self.deck[6];
        self.player_card5.text = self.deck[8];
        self.player_card6.text = self.deck[10];
        self.player_card7.text = self.deck[12];
        
        self.opponent_card4.hidden = YES;
        self.opponent_card5.hidden = YES;
        self.opponent_card6.hidden = YES;
        self.opponent_card7.hidden = YES;
        self.player_card4.hidden = YES;
        self.player_card5.hidden = YES;
        self.player_card6.hidden = YES;
        self.player_card7.hidden = YES;
        
    }
    [self.view setNeedsDisplay];
    [self.view drawRect:[[UIScreen mainScreen] applicationFrame]];
}

- (void)opencard
{
    NSLog(@"%s", __func__);
    if (self.player_card4.hidden == YES) {
        self.player_card4.hidden = NO;
        self.opponent_card4.hidden = NO;
        [self.view setNeedsDisplay];
        return;
    };
    if (self.player_card5.hidden == YES) {
        self.player_card5.hidden = NO;
        self.opponent_card5.hidden = NO;
        [self.view setNeedsDisplay];
        return;
    };
    if (self.player_card6.hidden == YES) {
        self.player_card6.hidden = NO;
        self.opponent_card6.hidden = NO;
        [self.view setNeedsDisplay];
        return;
    };
    if (self.player_card7.hidden == YES) {
        self.player_card7.hidden = NO;
        self.opponent_card7.hidden = NO;
        [self.view setNeedsDisplay];
        return;
    };
    
}

# pragma mark - SessionHelperDelegate methods
-(void)receivedMessage:(NSString *)message
{
    NSLog(@"%s", __func__);
    if ([message isEqualToString:@"deal"]){
        [self opencard];
    }
}

@end
