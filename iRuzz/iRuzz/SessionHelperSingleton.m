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
    int count = (int)[self.session.connectedPeers count];
    NSLog(@"count is %d", count);
    NSLog(@"displayName is %@", displayName);
    
    for (int i = 0; i < count; i++){
        MCPeerID *p_id = self.session.connectedPeers[i];
        NSLog(@"%@", p_id.displayName);
        
        if ([displayName isEqualToString: p_id.displayName]){
            NSLog(@"select %@", p_id.displayName);
            self.selectedPeerID = self.session.connectedPeers[i];
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
    int count = (int)[self.session.connectedPeers count];
    for (int i = 0; i < count; i++){
        [self.session cancelConnectPeer:self.session.connectedPeers[i]];
    }
//    [self.invitationSendingList removeAllObjects];
}
/**
 displayName以外のPeerをキャンセルする
 */
-(void)cancelConectWithoutPeer:(NSString*)displayName
{
    int count = (int)[self.session.connectedPeers count];
    for (int i = 0; i < count; i++){
        MCPeerID *peerID = self.session.connectedPeers[i];
        if (![peerID.displayName isEqualToString:displayName]){
            [self.session cancelConnectPeer:self.session.connectedPeers[i]];
        }
    }
}






# pragma mark - MCNearbyServiceBrowserDelegate methods
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    
    [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:5];
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
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    NSLog(@"%s", __func__);

    invitationHandler(YES, self.session);

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

        // ステータスが変わったことを知らせる
        [self.delegate didChangeState:peerID state:state];
    });

}


- (void)terminate{
    sharedData_ = nil;
}





@end
