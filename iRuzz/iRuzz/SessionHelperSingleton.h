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
-(void)sessionConnected:(NSString *)displayName;
-(void)receivedDeck:(Deck *)deck displayName:(NSString *)displayName;
-(void)receivedMessage:(NSString *)message;
-(void)lostPeerWithDisplayName:(NSString *)displayName;
-(void)sessionNotConnected;


@end

@interface SessionHelperSingleton : NSObject

+ (SessionHelperSingleton *)sharedManager;


@property MCSession *session;
@property MCPeerID *myPeerID;
@property NSMutableArray *connectedPeerList;    // MCSessionのconnectedPeersを使えばいいのかも

@property MCPeerID *selectedPeerID;
@property NSString *currentDelegateClassName;


@property (nonatomic, weak) id <SessionHelperDelegate> delegate;


- (void)startBrowsiongWithDisplayName:(NSString *)displayName;
- (void)startAdvertisingWithDisplayName:(NSString *)displayName;

-(BOOL)sendDeck:(NSData *)deck;
-(BOOL)sendMessage:(NSString *)message;
-(void)stopBrowsingAndAdvertising;

-(BOOL)setSelectedPeerIDWithDisplayName:(NSString *)displayName;
-(void)cancelConect;




@end
