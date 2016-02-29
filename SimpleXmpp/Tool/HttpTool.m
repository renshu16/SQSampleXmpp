//
//  HttpTool.m
//  SimpleXmpp
//
//  Created by ToothBond on 16/2/29.
//  Copyright © 2016年 ToothBond. All rights reserved.
//

#import "HttpTool.h"

#define kTimeOut 30.0

@interface HttpTool()<NSURLSessionTaskDelegate>
{
    HttpToolProgressBlock _downloadProgressBlock;
    HttpToolCompletionBlock _downloadCompletionBlock;
    NSURL *_downloadURL;
    
    HttpToolProgressBlock _uploadProgressBlock;
    HttpToolCompletionBlock _uploadCompletionBlock;
    
}

@end

@implementation HttpTool

-(void)uploadData:(NSData *)data url:(NSURL *)url progressBlock:(HttpToolProgressBlock)progressBlock completion:(HttpToolCompletionBlock)completionBlock
{
    NSAssert(data != nil, @"上传数据不能为空");
    NSAssert(url != nil, @"上传文件路径不能为空");
    
    _uploadProgressBlock = progressBlock;
    _uploadCompletionBlock = completionBlock;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOut];
    request.HTTPMethod = @"PUT";
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data];
    [uploadTask resume];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (_uploadProgressBlock) {
        CGFloat progress = (CGFloat)totalBytesSent/totalBytesExpectedToSend;
        _uploadProgressBlock(progress);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (_uploadCompletionBlock) {
        _uploadCompletionBlock(error);
        
        _uploadCompletionBlock = nil;
        _uploadProgressBlock = nil;
    }
}

#pragma mark - 下载
-(void)downLoadFromURL:(NSURL *)url progressBlock:(HttpToolProgressBlock)progressBlock completion:(HttpToolCompletionBlock)completionBlock
{
    NSAssert(url != nil, @"下载URL不能传空");
    
    _downloadURL = url;
    _downloadProgressBlock = progressBlock;
    _downloadCompletionBlock = completionBlock;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOut];
    
    NSURLResponse *response = nil;
    //发达同步请求
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    NSLog(@"%lld",response.expectedContentLength);
    if (response.expectedContentLength <= 0) {
        if (_downloadCompletionBlock) {
            NSError *error =[NSError errorWithDomain:@"文件不存在" code:404 userInfo:nil];
            _downloadCompletionBlock(error);
            
            //清除block
            _downloadCompletionBlock = nil;
            _downloadProgressBlock = nil;
        }
        return;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    
    //NSURLSessionDownloadDelegate
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    
    //定义下载操作
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    
    [downloadTask resume];
}

#pragma mark -NSURLSessionDownloadDelegate
#pragma mark 下载完成
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    //图片保存在沙盒的Doucument下
    NSString *fileSavePath = [self fileSavePath:[_downloadURL lastPathComponent]];
    
    //文件管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtURL:location toURL:[NSURL fileURLWithPath:fileSavePath] error:nil];
    
    if (_downloadCompletionBlock) {
        //通知下载成功，没有没有错误
        _downloadCompletionBlock(nil);
        
        //清空block
        _downloadCompletionBlock = nil;
        _downloadProgressBlock = nil;
    }
    
}

#pragma mark 下载进度
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    
    if (_downloadProgressBlock) {
        //已写数据字节数除以总字节数就是下载进度
        CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
        
        _downloadProgressBlock(progress);
        
    }
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}


#pragma mark -传一个文件名，返回一个在沙盒Document下的文件路径
-(NSString *)fileSavePath:(NSString *)fileName{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //图片保存在沙盒的Doucument下
    return [document stringByAppendingPathComponent:fileName];
}


@end
