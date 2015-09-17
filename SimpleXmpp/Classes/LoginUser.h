//
//  LoginUser.h
//  SimpleXmpp
//
//  Created by ToothBond on 15/9/17.
//  Copyright (c) 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

#define kTBXMPPUserName         @"kTBXMPPUserName"
#define kTBXMPPUserPassword     @"kTBXMPPUserPassword"
#define kTBXMPPUserHost         @"kTBXMPPUserHost"

@interface LoginUser : NSObject
single_interface(LoginUser)

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *hostName;

@property (strong, nonatomic, readonly) NSString *myJIDName;
@end
