//
//  SessionHelperSingleton.m
//  test
//
//  Created by ryo on 2015/01/18.
//  Copyright (c) 2015年 ryo. All rights reserved.
//

#import "SessionHelperSingleton.h"
#import "Deck.h"

@interface SessionHelperSingleton ()<MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>
@property NSString *serviceType;

@property MCNearbyServiceAdvertiser *nearbyServiceAdvertiser;
@property MCNearbyServiceBrowser *nearbyServiceBrowser;
@property NSMutableArray *invitationSendingList;


@end

@implementation SessionHelperSingleton

static SessionHelperSingleton *sharedData_ = nil;


+ (SessionHelperSingleton *)sharedManager{
    @synchronized(self){
        if (!sharedData_) {
            sharedData_ = [SessionHelperSingleton new];
            
        }
    }
    return sharedData_;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
        self.connectedPeerList = [NSMutableArray array];
        self.invitationSendingList = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Private methods

/**
 displayNameを元にsessionを作成する
 */
-(void)setPeerIDWithDisplayName:(NSString *)displayName
{
    NSLog(@"%s", __func__);
    if (self.serviceType == nil){
        
        self.myPeerID = [[MCPeerID alloc] initWithDisplayName:displayName];
        self.serviceType = @"irazz-test";
        
        self.session = [[MCSession alloc] initWithPeer:self.myPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
    }
}




#pragma mark - Public methods
- (void)startBrowsiongWithDisplayName:(NSString *)displayName

{
    NSLog(@"%s", __func__);

    [self setPeerIDWithDisplayName:displayName];
    
    
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeerID serviceType:self.serviceType];
    self.nearbyServiceBrowser.delegate = self;
    
    [self.nearbyServiceBrowser startBrowsingForPeers];
}

-(void)startAdvertisingWithDisplayName:(NSString *)displayName
{
    NSLog(@"%s", __func__);
    [self setPeerIDWithDisplayName:displayName];
    
    self.nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeerID discoveryInfo:nil serviceType:self.serviceType];
    self.nearbyServiceAdvertiser.delegate = self;
    [self.nearbyServiceAdvertiser startAdvertisingPeer];

}


-(BOOL)sendDeck:(NSData *)deck
{
    NSLog(@"%s", __func__);
    NSDictionary *deck_dir = @{@"deck":deck};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:deck_dir];

    if (self.selectedPeerID != nil){
        NSError *error;
        [self.session sendData:data
                  toPeers:@[self.selectedPeerID]
                 withMode:MCSessionSendDataReliable
                    error:&error];
        if (error) {
            NSLog(@"Failed %@", error);
            return NO;

        }
        return YES;

    }else{
        NSLog(@"skip");
        return NO;

    }

}

-(BOOL)sendMessage:(NSString *)message
{
    NSLog(@"%s", __func__);
    NSLog(@"message is %@", message);

    NSDictionary *message_dir = @{@"message":message};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:message_dir];
    if (self.selectedPeerID != nil){
        NSError *error;
        [self.session sendData:data
                       toPeers:@[self.selectedPeerID]
                      withMode:MCSessionSendDataReliable
                         error:&error];
        if (error) {
            NSLog(@"Failed %@", error);
            return NO;

        }

        NSLog(@"succeed send message");
        return YES;
    }else{
        
        NSLog(@"skip");
        return NO;
    }
}


-(void)stopBrowsingAndAdvertising
{
    NSLog(@"%s", __func__);
    
    [self.nearbyServiceBrowser stopBrowsingForPeers];
    [self.nearbyServiceAdvertiser stopAdvertisingPeer];
    
}

-(BOOL)setSelectedPeerIDWithDisplayName:(NSString *)displayName
{
    int count = (int)[self.connectedPeerList count];
    NSLog(@"count is %d", count);
    NSLog(@"displayName is %@", displayName);
    
    for (int i = 0; i < count; i++){
        MCPeerID *p_id = self.connectedPeerList[i];
        NSLog(@"%@", p_id.displayName);
        
        if ([displayName isEqualToString: p_id.displayName]){
            NSLog(@"select %@", p_id.displayName);
            self.selectedPeerID = self.connectedPeerList[i];
            return YES;
            break;
        }
    }
    return NO;
    
}

/**
 接続をキャンセルする
 **/
-(void)cancelConect
{
    NSLog(@"%s", __func__);
    int count = (int)[self.connectedPeerList count];
    for (int i = 0; i < count; i++){
        [self.session cancelConnectPeer:self.connectedPeerList[i]];
    }
    [self.connectedPeerList removeAllObjects];
    [self.invitationSendingList removeAllObjects];
}





# pragma mark - MCNearbyServiceBrowserDelegate methods
/**
 招待を受けたときに、自分のdisplayNameと相手のdisplayNameを比較し、
 辞書順？で自分のdisplayNameが小さい場合のみ招待を送る。
 (招待を受けるのは、自分のdisplayNameより大きい場合のみ)
 */
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    
    NSLog(@"%@", peerID.displayName);
    if ([self.connectedPeerList containsObject:peerID]){
        NSLog(@"再接続");
        [self.delegate sessionConnected:[peerID displayName]];
    }else{
        // 見つかったpeerIDに対して招待を送る
        // 送信中のものには送らない
        // 連続して招待を送っているような気がしたので、
        // 招待を送信中の判断と、招待を送る側(displayが小さい方)の判断をした
        // しかし、招待を送信中のログが出力されることはない？
        if(![self.invitationSendingList containsObject:peerID.displayName]){
            NSLog(@"招待送信中のリストに%@はない",peerID.displayName);
            NSComparisonResult result = [peerID.displayName  compare:self.myPeerID.displayName];
            switch (result) {
                case NSOrderedSame: // 一致
                    break;
                case NSOrderedAscending: // peerID.displayName が小さい
                    // 招待を送る
                    NSLog(@"招待を送る");
                    [self.invitationSendingList addObject:peerID.displayName];
                    [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:5];
                    break;
                case NSOrderedDescending: // peerID.displayName が大きい
                    NSLog(@"招待を送らない");
                    break;
                    
                default:
                    break;
            }
        }else{
            NSLog(@"%@には招待を送信中",peerID.displayName);

        }
    }
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"%s",__func__);
    
    [self.delegate lostPeerWithDisplayName:peerID.displayName];
    
}

# pragma mark - MCNearbyServiceBrowserDelegate optional methods
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"%s",__func__);
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}


# pragma mark - MCNearbyServiceAdvertiserDelegate methods
/**
 招待を受けたときに、自分のdisplayNameと相手のdisplayNameを比較し、
 辞書順で自分のdisplayNameが大きい場合のみ招待を受ける。
 (招待を送るのは、自分のdisplayNameより小さい場合のみ)
 */
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"%s", __func__);

    NSComparisonResult result = [peerID.displayName  compare:self.myPeerID.displayName];
    switch (result) {
        case NSOrderedSame: // 一致
            break;
        case NSOrderedAscending: // peerID.displayName が小さい
            NSLog(@"招待を受けない");
            
            break;
        case NSOrderedDescending: // peerID.displayName が大きい
            // 招待を受ける
            NSLog(@"招待を受ける");
            invitationHandler(YES, self.session);
            break;
            
        default:
            break;
    }
}

# pragma mark - MCNearbyServiceAdvertiserDelegate optional methods
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"%s",__func__);
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}



#pragma mark - MCSessionDelegate methods
// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%s",__func__);
    
    NSDictionary *reverse = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{

    if (([reverse objectForKey:@"uuid"] != nil) == TRUE) {

    } else if ((([reverse objectForKey:@"deck"] != nil) == TRUE)) { // deck
        NSData *data = reverse[@"deck"];
        
        
        [self.delegate receivedDeck:[NSKeyedUnarchiver unarchiveObjectWithData:data] displayName:peerID.displayName];

    } else if ((([reverse objectForKey:@"message"] != nil) == TRUE)) {
        NSString *message = reverse[@"message"];
        
            [self.delegate receivedMessage:message];
    }
    });

}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"%s",__func__);
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"%s",__func__);
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"%s",__func__);
}

// Remote peer changed state
/**
 このメソッドは別スレッドで呼ばれるらしい。
 よって、ここではメインスレッドで処理するようにしている。
 */
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"%s", __func__);
    NSLog(@"%@", peerID.displayName);

    // メインスレッドで処理を実行
    dispatch_async(dispatch_get_main_queue(), ^{

        if (state == MCSessionStateConnected){
            NSLog(@"接続完了");
            if ([self.invitationSendingList containsObject:peerID.displayName]){
                NSLog(@"送信中のリストから%@を削除", peerID.displayName);
                [self.invitationSendingList removeObject:peerID.displayName];
            }
            
            // connectedPeerListに接続が完了したpeerIDがあるかを検索
            // なければconnectedPeerListに追加
            BOOL isFound = NO;
            int count = (int)[self.connectedPeerList count];
            NSLog(@"count is %d", count);
            for (int i = 0; i < count; i++){
                MCPeerID *p_id = self.connectedPeerList[i];
                if ([peerID.displayName isEqualToString: p_id.displayName]){
                    NSLog(@"%@", p_id.displayName);
                    isFound = YES;
                    break;
                }
            }
            if (isFound == NO){
                [self.connectedPeerList addObject:peerID];
                NSLog(@"%@を追加", peerID.displayName);
                
                    // 他のピアの接続状態が変化したことをViewControllerに通知
                    [self.delegate sessionConnected:[peerID displayName]];
            }
            
        }else if (state == MCSessionStateNotConnected){
            NSLog(@"接続が切れた");
            if (self.selectedPeerID != nil){
                NSLog(@"%@",self.selectedPeerID.displayName);
                
            }else{
                NSLog(@"self.selectedPeerID is nil");
            }
            

            // connectedPeerListに接続が切れたpeerIDがあるかを検索
            // なければconnectedPeerListから削除
            int count = (int)[self.connectedPeerList count];
            NSLog(@"count is %d", count);
            for (int i = 0; i < count; i++){
                MCPeerID *p_id = self.connectedPeerList[i];

                if ([peerID.displayName isEqualToString: p_id.displayName]){
                    
                    NSLog(@"%@", self.connectedPeerList[i]);
                    [self.connectedPeerList removeObjectAtIndex:i];
                    break;
                }
            }
            
            if ([peerID.displayName isEqualToString: self.selectedPeerID.displayName]){
                
                self.selectedPeerID = nil;
                [self.delegate sessionNotConnected];
            }

        }
        else{
            NSLog(@"その他の接続状態");
        //sbremoveObject:peerID;
            
        }
    });

}


- (void)terminate{
    sharedData_ = nil;
}





@end
