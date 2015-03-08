//
//  SessionHelperSingleton.h
//  test
//
//  Created by ryo on 2015/01/18.
//  Copyright (c) 2015年 ryo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;


@class Deck;
@protocol SessionHelperDelegate <NSObject>

// SessionHelperDelegateで実装が必須なメソッド
@required
-(void)receivedDeck:(Deck *)deck displayName:(NSString *)displayName;
-(void)receivedMessage:(NSString *)message;
-(void)foundPeer;
-(void)lostPeer;
-(void)didChangeState:(MCPeerID *)peerID state:(MCSessionState)state;

@optional


@end

@interface SessionHelperSingleton : NSObject

+ (SessionHelperSingleton *)sharedManager;


@property MCSession *session;
@property MCPeerID *myPeerID;

@property MCPeerID *selectedPeerID;
@property NSMutableArray *foungPeerIDList;
@property BOOL isHost;


@property (nonatomic, weak) id <SessionHelperDelegate> delegate;

-(void)setPeerIDWithDisplayName:(NSString *)displayName;
//- (void)startBrowsiongWithDisplayName:(NSString *)displayName;
//- (void)startAdvertisingWithDisplayName:(NSString *)displayName;
- (void)startBrowsiongWithDisplayName;
- (void)startAdvertisingWithDisplayName;

-(BOOL)sendDeck:(NSData *)deck;
-(BOOL)sendMessage:(NSString *)message;
-(void)stopBrowsing;
-(void)stopdAvertising;
-(BOOL)setSelectedPeerIDWithDisplayName:(NSString *)displayName;
-(void)cancelConect;
-(void)cancelConectWithoutPeer:(NSString*)displayName;

-(BOOL)sendInvitePeerWithDisplayName:(NSString *)displayName;





@end
