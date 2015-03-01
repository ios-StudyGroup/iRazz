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
    }
    return self;
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

-(void)sendDeck:(NSData *)deck
{
    NSDictionary *deck_dir = @{@"deck":deck};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:deck_dir];

    NSError *error;
    [self.session sendData:data
              toPeers:@[self.connectedPeerID]
             withMode:MCSessionSendDataReliable
                error:&error];
    if (error) {
        NSLog(@"Failed %@", error);
    }

}

-(void)sendMessage:(NSString *)message
{
    NSDictionary *message_dir = @{@"message":message};
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:message_dir];
    
    NSError *error;
    [self.session sendData:data
                   toPeers:@[self.connectedPeerID]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    if (error) {
        NSLog(@"Failed %@", error);
    }

    
}





# pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"招待"
                                                                             message:[NSString stringWithFormat:@"%@ を招待しますか？",peerID.displayName]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          // はいボタンが押された時の処理
                                                          [self.nearbyServiceBrowser invitePeer:peerID toSession:self.session withContext:nil timeout:5];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // cancelボタンが押された時の処理
//        [self.nearbyServiceBrowser stopBrowsingForPeers];
        
    }]];
    [self.nearbyServiceBrowser stopBrowsingForPeers];


    
    UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
        baseView = baseView.presentedViewController;
    }
    [baseView presentViewController:alertController animated:YES completion:nil];

}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"%s",__func__);
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

    [self.nearbyServiceAdvertiser stopAdvertisingPeer];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"招待"
                                                                             message:[NSString stringWithFormat:@"%@ からの招待を受けますか？",peerID.displayName] preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // はいボタンが押された時の処理
        invitationHandler(YES, self.session);
        
        
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // cancelボタンが押された時の処理
    }]];
    
    
    UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
        baseView = baseView.presentedViewController;
    }
    [baseView presentViewController:alertController animated:YES completion:nil];

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

    if (([reverse objectForKey:@"uuid"] != nil) == TRUE) {

    } else if ((([reverse objectForKey:@"deck"] != nil) == TRUE)) { // deck
        NSData *data = reverse[@"deck"];
        
        
        [self.delegate receivedDeck:[NSKeyedUnarchiver unarchiveObjectWithData:data]];

    } else if ((([reverse objectForKey:@"message"] != nil) == TRUE)) {
        NSString *message = reverse[@"message"];
        [self.delegate receivedMessage:message];
    }
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
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    //NSLog(@"%s", __func__);
    if (state == MCSessionStateConnected){
        _connectedPeerID = peerID;
        [self.delegate sessionConnected];
    }else if (state == MCSessionStateNotConnected){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                                 message:@"接続が切れた"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // はいボタンが押された時の処理
            
        }]];
        
        UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
            baseView = baseView.presentedViewController;
        }
        [baseView presentViewController:alertController animated:YES completion:nil];

    }
    else{
        NSLog(@"%s", __func__);
//sbremoveObject:peerID;
        
    }
}

- (void)terminate{
    sharedData_ = nil;
}

@end
