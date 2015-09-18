//
//  AppDelegate.h
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/14.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginUser.h"
#define kTBNotifyUserLoginState @"kTBNotifyUserLoginState"
//
//#define kFriendJid      @"rensq@192.168.1.25"//@"lisi@wjmac.local"
//
//typedef void (^CompletionBlock)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


//@property (strong, nonatomic, readonly)XMPPStream *xmppStream;
//@property (strong, nonatomic, readonly)XMPPRoster *xmppRoster;
//@property (strong, nonatomic, readonly)XMPPRosterCoreDataStorage *xmppRosterStorage;
//
//@property (strong, nonatomic, readonly)XMPPMessageArchiving *xmppMessageArchiving;
//@property (strong, nonatomic, readonly)XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (assign, nonatomic) BOOL isRegister;
@property (assign, nonatomic) BOOL isLogin;
//
//-(void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)failed;
//
//-(void)disconnect;


@end

