//
//  MainVC.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/15.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "MainVC.h"
#import "Public.h"
#import "AppDelegate.h"
#import "ChatDetailVC.h"

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
    
    cellArr = [NSArray arrayWithObjects:@"聊天", @"注销",  nil];
    
    
//    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    logoutBtn.bounds = CGRectMake(0, 0, ScreenWidth - 80, 44);
//    logoutBtn.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
//    [logoutBtn setTitle:@"注销" forState:UIControlStateNormal];
//    [logoutBtn addTarget:self action:@selector(logoutClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:logoutBtn];
    
    

}

-(void)logoutClick:(UIButton *)btn
{
    [self appDelegate].isLogin = NO;
    
    [[self appDelegate] disconnect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTBNotifyUserLoginState object:nil];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    if (rowIndex == 0) {
        ChatDetailVC *chatDetail = [[ChatDetailVC alloc]init];
        [self.navigationController pushViewController:chatDetail animated:YES];
    }else if(rowIndex == 1){
        [self logoutClick:nil];
    }
}

@end
