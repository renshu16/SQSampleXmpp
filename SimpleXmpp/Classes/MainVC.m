//
//  MainVC.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/15.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "MainVC.h"
#import "LoginVC.h"
#import "Public.h"
#import "AppDelegate.h"
#import "ChatDetailVC.h"
#import "TBXmppManager.h"

@interface MainVC ()
{
    NSArray *cellArr;
}

@end

@implementation MainVC

-(AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerNotify];
    
    //self.view.backgroundColor = [UIColor yellowColor];
    self.title = @"主页";
    cellArr = [NSArray arrayWithObjects:@"添加好友",@"聊天",@"登录", @"注销",@"检查用户",@"request hello",@"发消息",@"tbmsgreply",@"HttpRequest",  nil];
    
    

}

-(void)dealloc
{
    [self removeNotify];
}

-(void)registerNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:kTBNotifyReceiveMsg object:nil];
}
-(void)removeNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTBNotifyReceiveMsg object:nil];
}

-(void)logoutClick:(UIButton *)btn
{
    //[self appDelegate].isLogin = NO;
    
    [[TBXmppManager sharedInstance] disconnect];
    NSDictionary *loginDic = @{kTBNotifyLoginKey:@"0"};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBNotifyUserLoginState object:loginDic];
}

#pragma mark - 添加好友
- (void)addFriendWithName:(NSString *)name
{
    // 1. 判断输入是否由域名
    NSRange range = [name rangeOfString:@"@"];
    
    if (NSNotFound == range.location) {
        // 2. 如果没有，添加域名合成完整的JID字符串
        // 在name尾部添加域名
        name = [NSString stringWithFormat:@"%@@%@", name, [LoginUser sharedLoginUser].hostName];
    }
    
    // 3. 判断是否与当前用户相同
    if ([name isEqualToString:[LoginUser sharedLoginUser].myJIDName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"自己不用添加自己！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //4.判断是否已经是好友
    if ([[[TBXmppManager sharedInstance] xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name] xmppStream:[[TBXmppManager sharedInstance] xmppStream ]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该用户已经是好友，无需添加！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    //5.发送添加好友的请求
    [[[TBXmppManager sharedInstance] xmppRoster] subscribePresenceToUser:[XMPPJID jidWithString:name]];
    
    NSLog(@"添加好友请求已发送 -- %@",name);
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    cell.textLabel.text = [cellArr objectAtIndex:[indexPath row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger rowIndex = [indexPath row];
    if (rowIndex == 0) {
        [self addFriendWithName:kFriendJid];
    }
    else if (rowIndex == 1 && [[self appDelegate] isLogin]) {
        //先添加好友，再进聊天列表
        
        ChatDetailVC *chatDetail = [[ChatDetailVC alloc]initWithJid:kFriendJid];
        [self.navigationController pushViewController:chatDetail animated:YES];
    }else if(rowIndex == 2 && ![[self appDelegate] isLogin]){
        LoginVC *loginVc = [[LoginVC alloc]init];
        [self.navigationController presentViewController:loginVc animated:YES completion:nil];
    }
    else if(rowIndex == 3 && [[self appDelegate] isLogin]){
        [self logoutClick:nil];
    }
    else if(rowIndex == 4){
        [[TBXmppManager sharedInstance] checkUser:kFriendJid];
    }
    else if(rowIndex == 5){
        [[TBXmppManager sharedInstance] requestHello:@"Hello from iOS"];
    }
    else if(rowIndex == 6){
//        [[TBXmppManager sharedInstance] sendTextMsg:@"{success:1}" toJID:@"huangcheng@192.168.1.140"];
        [[TBXmppManager sharedInstance] sendTextMsg:@"{success:1}" toJID:@"acweb_2f213adc-3480-4773-b75b-363fa8944f922222@192.168.1.51"];
//            [[TBXmppManager sharedInstance] sendTextMsg:@"{\"success\":1}" toJID:@"acweb@broadcast.192.168.3.140"];
    }
    else if(rowIndex == 7){
        [[TBXmppManager sharedInstance] sendTBMsgRequest];
    }
    else if(rowIndex == 8){
        [self sendHttpRequest];
    }
}

#pragma mark - Notifycation
-(void)didReceiveMessage:(NSNotification *)notify
{
//    id msg = notify !=nil && notify.object !=nil ? [notify.object objectForKey:kTBNotifyMsgKey] : nil;
//    if (msg) {
//        XMPPMessage *message = (XMPPMessage *)msg;
//        
//        dispatch_queue_t mainQueue= dispatch_get_main_queue();
//        dispatch_sync(mainQueue, ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"来自openfire的消息"
//                                                            message:[NSString stringWithFormat:@"%@",message ]
//                                                           delegate:self
//                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        });
//        
//
//    }
}

-(void)sendHttpRequest
{
    NSString *urlString = @"http://192.168.1.140:9090/plugins/presence/status?jid=zhangsan@192.168.1.140&type=text";
//    NSString *urlString = @"http://192.168.1.140:9090/plugins/restapi/v1/system/properties";
    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:url];
//    [mReq setValue:@"Basic YWRtaW46YWRtaW4=" forHTTPHeaderField:@"Authorization"];
//    [mReq setValue:@"application/json" forHTTPHeaderField:@"ContentType"];
    
    [NSURLConnection sendAsynchronousRequest:mReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"request error : %@",connectionError.localizedDescription);
            return;
        }
        
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"result : %@",retDict);
        
    }];
}

@end
