//
//  ConnectTableViewController.m
//  iRazz
//
//  Created by ryo on 2015/03/02.
//  Copyright (c) 2015年 cat. All rights reserved.
//

#import "ConnectTableViewController.h"
#import "SessionHelperSingleton.h"
#import "Deck.h"
#import "HumGameViewController.h"
#import "ComGameViewController.h"



@interface ConnectTableViewController()<UITableViewDelegate, UITableViewDataSource, SessionHelperDelegate>

@property NSArray *sectionList;             // 現状@"対戦相手だけの配列
@property NSMutableArray *opponentList;     // 対戦相手のリスト
@property NSMutableDictionary *dataSource;  // これを基にテーブルを作成

@property BOOL isPeersCancel;

@property UIView *baseView;// 下地View
@property UILabel *noticeLabel;// 下地Label
@property UIActivityIndicatorView *indicator;// インジケーター



@end




@implementation ConnectTableViewController


-(id) init
{
    self = [super init];
    if (self != nil){
        
        // cancelボタンを加える
        // cancelボタンを押すと前の画面に戻る
        self.navigationItem.leftBarButtonItem = [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(canceled)];
        
        self.navigationItem.rightBarButtonItem = [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        
        
        
        
        SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
        sessionHelperSingleton.delegate = self;

        
        
    }
    return self;
}

/**
 * ビューがロードし終わったとき
 */
- (void)viewDidLoad
{
    NSLog(@"%s", __func__);
    
    [super viewDidLoad];
    
    // セクション名を設定する
    self.sectionList =  [NSArray arrayWithObjects:@"対戦相手", nil];
    
    
    // セルの項目を作成する
    self.opponentList =  [@[@"コンピュータ"] mutableCopy];
    
    
    // セルの項目をまとめる
    NSArray *datas = [NSArray arrayWithObjects:self.opponentList, nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:datas forKeys:self.sectionList];
    self.dataSource = [dic mutableCopy];
    NSLog(@"%@", self.dataSource);
    
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [sessionHelperSingleton setPeerIDWithDisplayName:[ud stringForKey:@"displayName"]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s", __func__);
    
    self.isPeersCancel = YES;
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    // デリゲートを設定(GameViewから戻った場合のことを考え、viewDidLoadではなくここで設定)
    sessionHelperSingleton.delegate = self;
    sessionHelperSingleton.isHost = NO;

    [sessionHelperSingleton cancelConect];
    
//    [self updateDataSource];

    [sessionHelperSingleton.foungPeerIDList removeAllObjects];
    // 対戦相手を見つける
    [sessionHelperSingleton startBrowsiongWithDisplayName];
    [sessionHelperSingleton startAdvertisingWithDisplayName];
}



- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s", __func__);

    [super viewWillDisappear:animated];

    // 現在の接続をすべてキャンセルしておく
    // Top画面の状態でメッセージなどを受け取らないようにするため
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton stopBrowsing];
    [sessionHelperSingleton stopdAvertising];
    
    if (self.isPeersCancel == YES ) // game画面への遷移時はキャンセルしない
    {
        // すべてのPeerとの接続をキャンセル
        [sessionHelperSingleton cancelConect];
    }
}


#pragma mark - Private methods

/**
 ナビゲーションのキャンセルボタンをタップときに呼ばれる
 前の画面に戻る
*/
-(void)canceled
{
    [self dismissViewControllerAnimated:NO completion:nil]; /* Close */
}

/**
 ナビゲーションのRefreshボタンをタップときに呼ばれる
*/
-(void)refresh
{
    // 対戦相手を見つける
 
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];

    [sessionHelperSingleton startBrowsiongWithDisplayName];
    [sessionHelperSingleton startAdvertisingWithDisplayName];

    [self updateDataSource];
}




-(void)animatingIndicatorAtPoint:(CGPoint)point {
    
    // (i) 下地Viewの作成
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 280)];// 下地の大きさ
    self.baseView.center = point;
    self.baseView.backgroundColor = [UIColor lightGrayColor];// 下地の色
    self.baseView.alpha = 0.6;
    self.baseView.layer.cornerRadius = 28;
    
    // (ii) 下地ラベルの作成
    self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 100)];// 文字ラベルの大きさ
    self.noticeLabel.center = CGPointMake(120, 210);// 下地での位置
    self.noticeLabel.textColor = [UIColor blueColor];// 文字の色
    self.noticeLabel.text = @" お待ちください... ";
    self.noticeLabel.font = [UIFont systemFontOfSize:30];// フォント設定
    self.noticeLabel.adjustsFontSizeToFitWidth = YES;// 文字補正
    [self.baseView addSubview:self.noticeLabel];
    
    // (iii) インジケーターの作成
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];// インジケーターの大きさ
    self.indicator.center = CGPointMake(120, 140);// 下地での位置
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;// スタイル
    self.indicator.color = [UIColor blueColor];// indicatorの色
    [self.baseView addSubview:self.indicator];
    
    // (iv) Animation Start!
    [self.indicator startAnimating];
    // ビューに追加
    [self.view addSubview:self.baseView];
}

-(void)stopAndRemoveIndicator {
    // 停止・除く
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    [self.baseView removeFromSuperview];
}


/**
 DataSourceをアップデートし、テーブルを更新
 DataSourceは、MCSessionのconnectedPeersを基にする
 */
-(void)updateDataSource
{
    NSLog(@"%s", __func__);
    
    // セルの項目を作成する
    self.opponentList =  [@[@"コンピュータ"] mutableCopy];
    
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    int count = (int)[sessionHelperSingleton.foungPeerIDList count];
    for (int i = 0; i < count; i++){
        MCPeerID *peerID = sessionHelperSingleton.foungPeerIDList[i];
        [self.opponentList addObject:peerID.displayName];
    }
    NSArray *datas = [NSArray arrayWithObjects:self.opponentList, nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:datas forKeys:self.sectionList];
    self.dataSource = [dic mutableCopy];
    [self.tableView reloadData];
    
    [self.tableView reloadData];
}

# pragma mark - SessionHelperDelegate methods




/**
 デッキを受け取ったときに呼ばれる。
 対戦相手が、自分のセルをタップしたときにデッキを送信してくる。
 */
-(void)receivedDeck:(Deck *)deck displayName:(NSString *)displayName
{
    NSLog(@"%s",__func__);
    
    NSString *storyboardWithName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        storyboardWithName = @"Main"; // iPadのストーリーボード名
    }else{
        storyboardWithName = @"Main_iPhone"; // iPhoneのストーリーボード名
    }
    
    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:storyboardWithName bundle:nil];
    
    HumGameViewController *humGameViewController = [secondStoryboard instantiateViewControllerWithIdentifier:@"PushHumGameScene"];
    
    humGameViewController.deck = deck;
    humGameViewController.isHost = NO;
    
    self.isPeersCancel = NO;
    [self presentViewController:humGameViewController animated:YES completion:nil];
}

-(void)receivedMessage:(NSString *)message
{
    NSLog(@"%s", __func__);
    // 何もしない
}


-(void)foundPeer
{
    NSLog(@"%s", __func__);
    [self updateDataSource];
}
/**
 接続相手を見失ったときに呼ばれる
 */
-(void)lostPeerWithDisplayName
{
    NSLog(@"%s", __func__);
    [self updateDataSource];

}

/**
 接続状態が変わったときに呼ばれる
 */
-(void)didChangeState:(MCPeerID *)peerID state:(MCSessionState)state
{
    NSLog(@"%s", __func__);

    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"%@ に接続完了",peerID.displayName);
            break;
        case MCSessionStateNotConnected:
            NSLog(@"%@, に接続できない",peerID.displayName);
        case MCSessionStateConnecting:
            NSLog(@"%@ に接続中", peerID.displayName);
        default:
            break;
    }
    
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton.foungPeerIDList removeAllObjects];
    
    [self stopAndRemoveIndicator];

    if (state != MCSessionStateConnected){
        [self updateDataSource];
        return;
    }
    
    NSLog(@"%@との接続完了", peerID.displayName);
    
    if (sessionHelperSingleton.isHost == YES){
        NSLog(@"%@へデッキを送信し、ゲーム画面に遷移", peerID.displayName);

        // 招待を送った側は、ここでselectedPeerIDを設定
        // 招待を受けた側は、招待を受け取った時点で、selectedPeerIDを設定
        sessionHelperSingleton.selectedPeerID = peerID;
        
        // Deckを送信
        Deck *deck = [[Deck alloc] init];
        // デッキを送信
        if ([sessionHelperSingleton sendDeck:[NSKeyedArchiver archivedDataWithRootObject:deck]] == NO){
            // デッキ送信に失敗したら、アラートを表示
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"Deckの送信に失敗" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }
        // Viewの遷移
        // ストーリーボードで作成したViewに遷移する
        NSString *storyboardWithName;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            storyboardWithName = @"Main"; // iPadのストーリーボード名
        }
        else{
            storyboardWithName = @"Main_iPhone"; // iPhoneのストーリーボード名
        }
        UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:storyboardWithName bundle:nil];
        HumGameViewController *humGameViewController = [secondStoryboard instantiateViewControllerWithIdentifier:@"PushHumGameScene"];
        
        
        humGameViewController.deck = deck;
        humGameViewController.isHost = YES;
        
        self.isPeersCancel = NO;
        [self presentViewController:humGameViewController animated:YES completion:nil];
    }
    
}


# pragma mark - UITableViewDataSourceDelegate methods
/**
 * テーブル全体のセクションの数を返す
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%s", __func__);

    return [self.sectionList count];
}

/**
 * 指定されたセクションのセクション名を返す
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"%s", __func__);

    return [self.sectionList objectAtIndex:section];
}

/**
 * 指定されたセクションの項目数を返す
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s", __func__);

    NSString *sectionName = [self.sectionList objectAtIndex:section];
    
    NSLog(@"%@", self.dataSource);
    return [[self.dataSource objectForKey:sectionName ]count];
}

/**
 * 指定された箇所のセルを作成する
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __func__);
    
    
    NSLog(@"%@", self.dataSource);

    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // セルが作成されていないか?
    if (!cell) { // yes
        // セルを作成
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // セクション名を取得する
    NSString *sectionName = [self.sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [self.dataSource objectForKey:sectionName];
    
    // セルにテキストを設定
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    return cell;
}

/**
 * セルが選択されたとき
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __func__);

    // セクション名を取得する
    NSString *sectionName = [self.sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [self.dataSource objectForKey:sectionName];
    
    NSLog(@"「%@」が選択されました", [items objectAtIndex:indexPath.row]);
    
    // ストーリーボードで作成したViewに遷移する
    NSString *storyboardWithName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        storyboardWithName = @"Main"; // iPadのストーリーボード名
    }
    else{
        storyboardWithName = @"Main_iPhone"; // iPhoneのストーリーボード名
    }

    
    if ([@"コンピュータ" isEqualToString:[items objectAtIndex:indexPath.row]]){
        // Viewの遷移
        UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:storyboardWithName bundle:nil];
        ComGameViewController *comGameViewController = [secondStoryboard instantiateViewControllerWithIdentifier:@"PushComGameScene"];
        [self presentViewController:comGameViewController animated:YES completion:nil];

    }else{
        SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
        // 招待を送る
        if ([sessionHelperSingleton sendInvitePeerWithDisplayName:[items objectAtIndex:indexPath.row]]){
            NSLog(@"招待の送信");
            sessionHelperSingleton.isHost = YES;
            
            // 指定した位置 に(Point指定で) インジケーターを表示する
            [self animatingIndicatorAtPoint:self.view.center];
            
            
        }else{
            NSLog(@"招待の送信に失敗");
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"招待に失敗" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 更新だけしとく
                [self.tableView reloadData];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];

        }

    }
}




@end