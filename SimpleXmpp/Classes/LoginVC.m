//
//  LoginVC.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/15.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import "Public.h"
#import "NSString+Helper.h"
#import "LoginUser.h"
#import "TBXmppManager.h"

@interface LoginVC ()

@property(nonatomic,strong)UITextField *userNameText;
@property(nonatomic,strong)UITextField *userPasswordText;
@property(nonatomic,strong)UITextField *hostNameText;

@end

@implementation LoginVC

-(AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    [self initViews];
}

-(void)initViews
{
    
    
    
    CGFloat textWidth = ScreenWidth - 80;
    _userNameText = [[UITextField alloc]initWithFrame:CGRectMake(40, 60, textWidth, 44)];
    [_userNameText setBorderStyle:UITextBorderStyleRoundedRect];
    _userNameText.backgroundColor = [UIColor whiteColor];
    [_userNameText setPlaceholder:@"请输入账号"];
    [_userNameText setDelegate:self];
    _userNameText.text = @"zhangsan";
    [self.view addSubview:_userNameText];
    
    _userPasswordText = [[UITextField alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(_userNameText.frame) + kPadding, textWidth, 44)];
    [_userPasswordText setBorderStyle:UITextBorderStyleRoundedRect];
    _userPasswordText.backgroundColor = [UIColor whiteColor];
    [_userPasswordText setPlaceholder:@"请输入密码"];
    _userPasswordText.secureTextEntry = YES;
    [_userPasswordText setDelegate:self];
    _userPasswordText.text = @"zhangsan";
    [self.view addSubview:_userPasswordText];
    
    _hostNameText = [[UITextField alloc]initWithFrame:CGRectMake(40, CGRectGetMaxY(_userPasswordText.frame) + kPadding, textWidth, 44)];
    [_hostNameText setBorderStyle:UITextBorderStyleRoundedRect];
    _hostNameText.backgroundColor = [UIColor whiteColor];
    [_hostNameText setPlaceholder:@"请输入主机名"];
    [_hostNameText setDelegate:self];
    [_hostNameText setText:kHostName];
    [self.view addSubview:_hostNameText];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(40, CGRectGetMaxY(_hostNameText.frame) + 20 , textWidth/2, 30);
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    loginBtn.tag = 1;
    [loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registBtn.frame = CGRectMake(CGRectGetMaxX(loginBtn.frame), CGRectGetMaxY(_hostNameText.frame) + 20 , textWidth/2, 30);
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    registBtn.tag = 2;
    [registBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userNameText) {
        [_userPasswordText becomeFirstResponder];
    }else if(textField == _userPasswordText){
        [_hostNameText becomeFirstResponder];
    }else if(textField == _hostNameText ){
        [_hostNameText resignFirstResponder];
    }
    return YES;
}

#pragma mark -action login and register
-(void)btnClick:(UIButton *)btn
{
    NSString *userName = [_userNameText.text trimString];
    NSString *password =  _userPasswordText.text;
    NSString *hostName = [_hostNameText.text trimString];
    
    if ([userName isEmptyString] ||
        [password isEmptyString] ||
        [hostName isEmptyString]) {
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录信息不完整" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    [[LoginUser sharedLoginUser] setUserName:userName];
    [[LoginUser sharedLoginUser] setPassword:password];
    [[LoginUser sharedLoginUser] setHostName:hostName];
    
    NSString *actionStr = @"";
    //登陆
    if (btn.tag == 1) {
        actionStr = @"登陆";
    }
    //注册
    else if (btn.tag == 2) {
        actionStr = @"注册";
        [TBXmppManager sharedInstance].isRegister = YES;
    }
    
    [[TBXmppManager sharedInstance] connectWithCompletion:^{
        NSLog(@"%@ -- 成功",actionStr);
        [self dismissViewControllerAnimated:YES completion:nil];
    } failed:^{
        NSLog(@"%@ -- 失败",actionStr);
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        
        if (btn.tag == 1) {
            // 注册用户失败通常是因为用户名重复
            [_userNameText becomeFirstResponder];
        } else {
            // 登录失败通常是密码输入错误
            [_userPasswordText setText:@""];
            [_userPasswordText becomeFirstResponder];
        }
    }];
    
}




@end
