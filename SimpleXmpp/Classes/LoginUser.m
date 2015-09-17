//
//  LoginUser.m
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/17.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import "LoginUser.h"
#import "NSString+Helper.h"

@implementation LoginUser
single_implementation(LoginUser)

- (NSString *)loadStringFromDefaultsWithKey:(NSString *)key
{
    NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    return (str) ? str : @"";
}

-(NSString *)userName
{
    return [self loadStringFromDefaultsWithKey:kTBXMPPUserName];
}

-(void)setUserName:(NSString *)userName
{
    [userName saveToNSDefaultsWithKey:kTBXMPPUserName];
}

- (NSString *)password
{
    return [self loadStringFromDefaultsWithKey:kTBXMPPUserPassword];
}

- (void)setPassword:(NSString *)password
{
    [password saveToNSDefaultsWithKey:kTBXMPPUserPassword];
}

- (NSString *)hostName
{
    return [self loadStringFromDefaultsWithKey:kTBXMPPUserHost];
}

- (void)setHostName:(NSString *)hostName
{
    [hostName saveToNSDefaultsWithKey:kTBXMPPUserHost];
}

-(NSString *)myJIDName
{
     return [NSString stringWithFormat:@"%@@%@", self.userName, self.hostName];
}

@end
