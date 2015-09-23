//
//  TBXmppManager.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/18.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "TBXmppManager.h"

@interface TBXmppManager ()
{
    CompletionBlock _completionBlock;
    CompletionBlock _failedBlock;
    
    XMPPReconnect *_xmppReconnect;
    
    //NSMutableArray *_socketList;
}

-(void)teardownStream;

-(void)goOnline;

-(void)goOffline;

@end

@implementation TBXmppManager

static TBXmppManager *sharedManager;
+(TBXmppManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[TBXmppManager alloc]init];
        //[DDLog addLogger:[DDTTYLogger sharedInstance]];
        
    });
    return sharedManager;
}

-(void)registerNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(loginStateChanged) name:kTBNotifyUserLoginState object:nil];
}

-(void)loginStateChanged
{
//    NSLog(@"%s",__FUNCTION__);
//    UIViewController *rootVc = nil;
//    if (_isLogin) {
//        MainVC *mainVC = [[MainVC alloc]init];
//        rootVc = [[UINavigationController alloc]initWithRootViewController:mainVC];
//    }else{
//        rootVc = [[LoginVC alloc]init];
//    }
//    if (self.window == nil) {
//        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//    }
//    self.window.rootViewController = rootVc;
//    [self.window makeKeyAndVisible];
}

#pragma mark - XMPP OutMethod
-(void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)failed
{
    _completionBlock = completion;
    _failedBlock = failed;
    if ([_xmppStream isConnected]) {
        [_xmppStream disconnect];
    }
    [self connect];
}

-(void)sendXmppMessage:(XMPPMessage *)message
{
    
}

#pragma mark - XMPP InnerMethod
-(void)setupStream
{
    if (_xmppStream != nil) {
        NSLog(@"XMPPStream 重复设置");
        return;
    }
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // 允许XMPPStream在真机运行时，支持后台网络通讯！
        [_xmppStream setEnableBackgroundingOnSocket:YES];
    }
#endif
    
    _xmppStream = [[XMPPStream alloc]init];
    
    _xmppReconnect = [[XMPPReconnect alloc]init];
    
    //_socketList = [NSMutableArray array];
    
    _xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_xmppRosterStorage];
    [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:YES];//自动接收好友订阅请求
    [_xmppRoster setAutoFetchRoster:YES];//自动刷新
    
    _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
    
    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppMessageArchiving activate:_xmppStream];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)teardownStream
{
    if (_xmppStream == nil) return;
    
    [_xmppStream removeDelegate:self];
    [_xmppReconnect deactivate];
    
    [_xmppStream disconnect];
    [_xmppRoster deactivate];
    [_xmppMessageArchiving deactivate];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
    _xmppRosterStorage = nil;
    _xmppRoster = nil;
    _xmppMessageArchiving = nil;
    _xmppMessageArchivingCoreDataStorage = nil;
}

-(void)connect
{
    if ([_xmppStream isConnected]) {
        return;
    }
    
    NSString *myJID = [[LoginUser sharedLoginUser] myJIDName];
    NSString *hostName = [[LoginUser sharedLoginUser] hostName];
    
    if ([myJID isEmptyString] || [hostName isEmptyString]) {
        //第一次登录
        
        return;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    [_xmppStream setHostName:hostName];
    
    NSError *err = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err];
    if (err) {
        NSLog(@"连接请求发送出错 - %@", err.localizedDescription);
    } else {
        NSLog(@"连接请求发送成功！");
    }
    
}

-(void)disconnect
{
    [self goOffline];
    [_xmppStream disconnect];
}

-(void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

-(void)goOffline
{
    XMPPPresence *offPresence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offPresence];
}

#pragma mark - XMPPDelegate
#pragma mark 建立连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"%s",__FUNCTION__);
    NSString *userPassword = [[LoginUser sharedLoginUser] password];
    if (_isRegister) {
        [_xmppStream registerWithPassword:userPassword error:nil];
    }else{
        [_xmppStream authenticateWithPassword:userPassword error:nil];
    }
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"%s",__FUNCTION__);
    _isRegister = NO;
    //注册成功转 自动登陆
    [self xmppStreamDidConnect:_xmppStream];
    
    [_xmppStream authenticateWithPassword:[[LoginUser sharedLoginUser] password] error:nil];
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"%s",__FUNCTION__);
    _isRegister = NO;
    if (_failedBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _failedBlock();
        });
    }
}

#pragma mark 登陆成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"%s",__FUNCTION__);
    NSDictionary *loginDic = @{kTBNotifyLoginKey:@"1"};
    [[NSNotificationCenter defaultCenter]postNotificationName:kTBNotifyUserLoginState object:loginDic];
    if (_completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _completionBlock();
        });
    }
    
    [self goOnline];
}

#pragma mark 登陆失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"%s",__FUNCTION__);
    if (_failedBlock) {
        _failedBlock();
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"接收到用户消息 - %@", message);
}

- (XMPPMessage *)xmppStream:(XMPPStream *)sender willReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"will接收到用户消息 - %@", message);
    return message;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"接收到用户登陆的状态 - %@",presence);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"didReceiveIQ - %@",iq);
    
    
    return YES;
}

#pragma mark - XMPPRoster Delegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
//    _xmppRoster rejectPresenceSubscriptionRequestFrom:<#(XMPPJID *)#>
//    _xmppRoster acceptPresenceSubscriptionRequestFrom:<#(XMPPJID *)#> andAddToRoster:<#(BOOL)#>
    NSLog(@"接收到来自%@的订阅请求",[presence from]);
}


#pragma mark - dealloc
-(void)dealloc
{
    [self teardownStream];
}


@end
