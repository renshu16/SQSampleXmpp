//
//  AppDelegate.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/14.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "MainVC.h"


@interface AppDelegate ()<XMPPStreamDelegate>
{
    CompletionBlock _completionBlock;
    CompletionBlock _failedBlock;
    
    XMPPReconnect *_xmppReconnect;
}

-(void)setStream;

-(void)teardownStream;

-(void)goOnline;

-(void)goOffline;

-(void)connect;

//-(void)disconnect;

@end

@implementation AppDelegate


-(void)registerNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(loginStateChanged) name:kTBNotifyUserLoginState object:nil];
}

-(void)loginStateChanged
{
    NSLog(@"%s",__FUNCTION__);
    UIViewController *rootVc = nil;
    if (_isLogin) {
        MainVC *mainVC = [[MainVC alloc]init];
        rootVc = [[UINavigationController alloc]initWithRootViewController:mainVC];
    }else{
        rootVc = [[LoginVC alloc]init];
    }
    if (self.window == nil) {
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    self.window.rootViewController = rootVc;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerNotification];
    
    [self loginStateChanged];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - XMPP Connect
-(void)connectWithCompletion:(CompletionBlock)completion failed:(CompletionBlock)failed
{
    _completionBlock = completion;
    _failedBlock = failed;
    if ([_xmppStream isConnected]) {
        [_xmppStream disconnect];
    }
    [self connect];
}

#pragma mark - AppInner
-(void)setStream
{
    if (_xmppStream != nil) {
        NSLog(@"XMPPStream 重复设置");
        return;
    }
    
    _xmppStream = [[XMPPStream alloc]init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    _xmppReconnect = [[XMPPReconnect alloc]init];
    
    _xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_xmppRosterStorage];
    
    _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
    
    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppMessageArchiving activate:_xmppStream];
    
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
    [self setStream];
    
    NSString *myJID = [[LoginUser sharedLoginUser] myJIDName];
    NSString *hostName = [[LoginUser sharedLoginUser] hostName];
    
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
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"%s",__FUNCTION__);
    _isRegister = NO;
    if (_failedBlock) {
        _failedBlock();
    }
}

#pragma mark 登陆成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"%s",__FUNCTION__);
    _isLogin = YES;
    if (_completionBlock) {
        _completionBlock();
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





#pragma mark - dealloc
-(void)dealloc
{
    [self teardownStream];
}

@end
