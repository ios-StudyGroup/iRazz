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
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s", __func__);
    
    self.isPeersCancel = YES;
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    // デリゲートを設定(GameViewから戻った場合のことを考え、viewDidLoadではなくここで設定)
    sessionHelperSingleton.delegate = self;
//    [sessionHelperSingleton cancelConect];
    
    [self updateDataSource];

    // 対戦相手を見つける
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [sessionHelperSingleton startBrowsiongWithDisplayName:[ud stringForKey:@"displayName"]];
    [sessionHelperSingleton startAdvertisingWithDisplayName:[ud stringForKey:@"displayName"]];
}



- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s", __func__);

    [super viewWillDisappear:animated];

    // 現在の接続をすべてキャンセルしておく
    // Top画面の状態でメッセージなどを受け取らないようにするため
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    [sessionHelperSingleton stopBrowsingAndAdvertising];
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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得

    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];

    [sessionHelperSingleton startBrowsiongWithDisplayName:[ud stringForKey:@"displayName"]];
    [sessionHelperSingleton startAdvertisingWithDisplayName:[ud stringForKey:@"displayName"]];

    [self updateDataSource];
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
    [sessionHelperSingleton.session.connectedPeers enumerateObjectsUsingBlock:^(MCPeerID *obj, NSUInteger idx, BOOL *stop) {
        [self.opponentList addObject:obj.displayName];
    }];
    
    NSLog(@"%@", self.opponentList);
    // セルの項目をまとめる
    NSArray *datas = [NSArray arrayWithObjects:self.opponentList, nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:datas forKeys:self.sectionList];
    self.dataSource = [dic mutableCopy];
    
    
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
    
    SessionHelperSingleton *sessionHelperSingleton = [SessionHelperSingleton sharedManager];
    if ([sessionHelperSingleton setSelectedPeerIDWithDisplayName:displayName]){
        NSLog(@"selectedPeerIDを設定");
        // displayName以外との接続をキャンセル
        [sessionHelperSingleton cancelConectWithoutPeer:displayName];
        self.isPeersCancel = NO;

        [self presentViewController:humGameViewController animated:YES completion:nil];
        
    }else{
        NSLog(@"接続されていないdisplayName");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"接続されていない相手です" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // 更新だけしとく
            [self updateDataSource];
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)receivedMessage:(NSString *)message
{
    NSLog(@"%s", __func__);
    // 何もしない
}

/**
 接続相手を見失ったときに呼ばれる
 */
-(void)lostPeerWithDisplayName:(NSString *)displayName
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
    [self updateDataSource];
    
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
        if ([sessionHelperSingleton setSelectedPeerIDWithDisplayName:[items objectAtIndex:indexPath.row]]){
            // 選択したセルの対戦相手が、接続状態にある場合
            // デッキを作成
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
            
            // 指定したdisplayName以外との接続をキャンセル
            [sessionHelperSingleton cancelConectWithoutPeer:[items objectAtIndex:indexPath.row]];
            self.isPeersCancel = NO;

            // Viewの遷移
            UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:storyboardWithName bundle:nil];
            HumGameViewController *humGameViewController = [secondStoryboard instantiateViewControllerWithIdentifier:@"PushHumGameScene"];
            
            
            humGameViewController.deck = deck;
            humGameViewController.isHost = YES;
            
            [self presentViewController:humGameViewController animated:YES completion:nil];
        }else{
            // 選択したセルの対戦相手が、接続状態にない場合
            // アラートを表示する
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"接続されていない相手です" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 更新だけしとく
                [self.tableView reloadData];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}




@end