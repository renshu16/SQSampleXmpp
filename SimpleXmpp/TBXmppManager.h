//
//  TBXmppManager.h
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/18.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "LoginUser.h"
#import "Public.h"

#define kTBNotifyUserLoginState @"kTBNotifyUserLoginState"
#define kTBNotifyLoginKey       @"login_key"

#define kTBNotifyReceiveMsg     @"kTBNotifyReceiveMsg"
#define kTBNotifyMsgKey         @"kTBNotifyMsgKey"

#define kFriendJid      @"lisi@192.168.1.140"

//#define kHostName       @"wjmac.local"
//#define kHostName       @"192.168.1.25"
#define kHostName       @"192.168.1.140"

typedef void (^CompletionBlock)();

@interface TBXmppManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

+(TBXmppManager *)sharedInstance;

@property (strong, nonatomic, readonly)XMPPStream *xmppStream;
@property (strong, nonatomic, readonly)XMPPRoster *xmppRoster;
@property (strong, nonatomic, readonly)XMPPRosterCoreDataStorage *xmppRosterStorage;

@property (strong, nonatomic, readonly)XMPPMessageArchiving *xmppMessageArchiving;
@property (strong, nonatomic, readonly)XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (assign, nonatomic) BOOL isRegister;
@property (assign, nonatomic) BOOL isLogin;

-(void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)failed;

-(void)sendXmppMessage:(XMPPMessage *)message;
-(void)sendTextMsg:(NSString *)message toJID:(NSString *)toJID;
-(void)checkUser:(NSString*)userName;
-(void)requestHello:(NSString *)sayStr;

-(void)setupStream;
-(void)connect;
-(void)disconnect;

@end
