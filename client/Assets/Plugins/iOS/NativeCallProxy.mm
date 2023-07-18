//
//  NativeCallProxy.m
//  TestSwiftDemo
//
//  Created by 777 on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "NativeCallProxy.h"
#import "SySwiftNetWork.h"
//如果c#调用oc函数时需要一个回调，需要先声明回调参数类型：
typedef void (*MyResultCallback) (int status,const char *result);

//在.m文件中以下4行可以不需要
#if defined (__cplusplus)
extern "C"
{
#endif

    // 调用热更文件方法
void DownloadPatch(const char * downloadConfPath, const char * resRoot, const char * cdnPath, int threadCount){
    NSLog(@"test===>downloadConfPath: %s, resRoot:%s, cdnPath:%s threadCount:%d", downloadConfPath, resRoot, cdnPath, threadCount);
    NSString *downloadConfPathStr = [[NSString alloc] initWithUTF8String:downloadConfPath];
    NSString *resRootStr = [[NSString alloc] initWithUTF8String:resRoot];
    NSString *cdnPathStr = [[NSString alloc] initWithUTF8String:cdnPath];

    [[SySwiftNetWork shareInstance] downloadFileWithConf:downloadConfPathStr rootPath:resRootStr patchPath:cdnPathStr threadCount:threadCount progress:^(NSString * _Nonnull fileName, BOOL isSuccess, NSString * _Nonnull msg) {
        
        if(isSuccess){
//            NSLog(@"单文件下载成功,文件名：%@",fileName);
            char* cString = (char*) [fileName UTF8String];
            UnitySendMessage("IosCompoent", "IosDownloadPatchSucc", cString);
        }else{
            NSLog(@"单文件下载失败,文件名：%@，返回信息：%@",fileName, msg);
            NSString * logMsg = [NSString stringWithFormat:@"%@<#>%@", fileName, msg];
            char* cMsg = (char*) [logMsg UTF8String];
            UnitySendMessage("IosCompoent", "IosDownloadPatchFail", cMsg);
        }
        
        } callBack:^(BOOL isAllSuccess) {
            if(isAllSuccess){
                NSLog(@"全部文件下载请求成功");
            }else{
                NSLog(@"部分文件请求失败");
            }
        }];
}

    void DownloadSubpack(const char * downloadConfPath, const char * resRoot, const char * cdnPath, int threadCount) {
        NSLog(@"test===>downloadConfPath: %s, resRoot:%s, cdnPath:%s threadCount:%d", downloadConfPath, resRoot, cdnPath, threadCount);
        NSString *downloadConfPathStr = [[NSString alloc] initWithUTF8String:downloadConfPath];
        NSString *resRootStr = [[NSString alloc] initWithUTF8String:resRoot];
        NSString *cdnPathStr = [[NSString alloc] initWithUTF8String:cdnPath];

        
        [[SySwiftNetWork shareInstance] downloadSubpackFileWithConf:downloadConfPathStr rootPath:resRootStr patchPath:cdnPathStr  threadCount:threadCount progress:^(NSString * _Nonnull fileName, BOOL isSuccess, NSString * _Nonnull msg) {
            
            if(isSuccess){
    //            NSLog(@"单文件下载成功,文件名：%@",fileName);
                char* cString = (char*) [fileName UTF8String];
                UnitySendMessage("IosCompoent", "IosDownloadSubpackageSucc", cString);
            }else{
                NSLog(@"单文件下载失败,文件名：%@，返回信息：%@",fileName, msg);
                NSString * logMsg = [NSString stringWithFormat:@"%@<#>%@", fileName, msg];
                char* cMsg = (char*) [logMsg UTF8String];
                UnitySendMessage("IosCompoent", "IosDownloadSubpackageFail", cMsg);
            }
            
            } callBack:^(BOOL isAllSuccess) {
                if(isAllSuccess){
                    NSLog(@"全部文件下载请求成功");
                }else{
                    NSLog(@"部分文件请求失败");
                }
            }];

    }

    void DownloadSubpackChgStatus(const char * status)
    {
        NSString *statusStr = [[NSString alloc] initWithUTF8String:status];
        NSLog(@"小包下载状态修改 status：%@",statusStr);
        
        [[SySwiftNetWork shareInstance] changeSubpackStatus:statusStr];
    }

    void OnIosDownloadSubpackFinish()
    {
        NSLog(@"关闭小包下载纯种");
        [[SySwiftNetWork shareInstance] downloadSubpackFinish];
    }

//在.m文件中以下3行可以不需要
#if defined (__cplusplus)
}
#endif
