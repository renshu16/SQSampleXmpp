//
//  HttpTool.h
//  SimpleXmpp 文件上传下载工具类
//
//  Created by ToothBond on 16/2/29.
//  Copyright © 2016年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^HttpToolProgressBlock)(CGFloat progress);
typedef void (^HttpToolCompletionBlock)(NSError *error);

@interface HttpTool : NSObject

-(void)uploadData:(NSData *)data
              url:(NSURL *)url
    progressBlock:(HttpToolProgressBlock)progressBlock
       completion:(HttpToolCompletionBlock)completionBlock;

-(void)downLoadFromURL:(NSURL *)url
         progressBlock:(HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock)completionBlock;

-(NSString *)fileSavePath:(NSString *)fileName;

@end
