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
    
    //self.view.backgroundColor = [UIColor yellowColor];
    self.title = @"主页";
    cellArr = [NSArray arrayWithObjects:@"聊天",@"登录", @"注销",  nil];
    
    

}

-(void)logoutClick:(UIButton *)btn
{
    //[self appDelegate].isLogin = NO;
    
    [[TBXmppManager sharedInstance] disconnect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBNotifyUserLoginState object:[NSNumber numberWithBool:NO]];
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
    NSInteger rowIndex = [indexPath row];
    if (rowIndex == 0 && [[self appDelegate] isLogin]) {
        ChatDetailVC *chatDetail = [[ChatDetailVC alloc]init];
        [self.navigationController pushViewController:chatDetail animated:YES];
    }else if(rowIndex == 1 && ![[self appDelegate] isLogin]){
        LoginVC *loginVc = [[LoginVC alloc]init];
        [self.navigationController presentViewController:loginVc animated:YES completion:nil];
    }
    else if(rowIndex == 2 && [[self appDelegate] isLogin]){
        [self logoutClick:nil];
    }
}

@end
