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
-(void)sessionConnected;
-(void)receivedDeck:(Deck *)deck;
-(void)receivedMessage:(NSString *)message;

@end

@interface SessionHelperSingleton : NSObject

+ (SessionHelperSingleton *)sharedManager;

//@property (nonatomic, readonly) MCSession *session;
//@property (nonatomic, readonly) MCPeerID *myPeerID;
//
//@property (nonatomic, readonly) MCPeerID *connectedPeerID;

@property MCSession *session;
@property MCPeerID *myPeerID;

@property MCPeerID *connectedPeerID;


@property (nonatomic, weak) id <SessionHelperDelegate> delegate;


- (void)startBrowsiongWithDisplayName:(NSString *)displayName;
- (void)startAdvertisingWithDisplayName:(NSString *)displayName;

-(void)sendDeck:(NSData *)deck;
-(void)sendMessage:(NSString *)message;




@end
