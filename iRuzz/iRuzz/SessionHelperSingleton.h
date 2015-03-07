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

@optional
-(void)receivedDeck:(Deck *)deck displayName:(NSString *)displayName;
-(void)receivedMessage:(NSString *)message;
-(void)lostPeerWithDisplayName:(NSString *)displayName;
-(void)didChangeState:(MCPeerID *)peerID state:(MCSessionState)state;


@end

@interface SessionHelperSingleton : NSObject

+ (SessionHelperSingleton *)sharedManager;


@property MCSession *session;
@property MCPeerID *myPeerID;

@property MCPeerID *selectedPeerID;


@property (nonatomic, weak) id <SessionHelperDelegate> delegate;


- (void)startBrowsiongWithDisplayName:(NSString *)displayName;
- (void)startAdvertisingWithDisplayName:(NSString *)displayName;

-(BOOL)sendDeck:(NSData *)deck;
-(BOOL)sendMessage:(NSString *)message;
-(void)stopBrowsingAndAdvertising;

-(BOOL)setSelectedPeerIDWithDisplayName:(NSString *)displayName;
-(void)cancelConect;
-(void)cancelConectWithoutPeer:(NSString*)displayName;





@end
