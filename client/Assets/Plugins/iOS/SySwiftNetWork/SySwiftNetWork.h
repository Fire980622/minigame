//
//  SySwiftNetWork.h
//  TestSwiftDemo
//
//  Created by zhouwenbin on 2023/4/3.
//

#import <Foundation/Foundation.h>


#import <UnityFramework/UnityFramework-Swift.h>


NS_ASSUME_NONNULL_BEGIN

 
@interface SySwiftNetWork : NSObject

+(instancetype)shareInstance;

///文件下载
///conf  要下载的文件列表
///rootPath 文件下载存放路径
///patchPath 文件下载请求路径
///threadCount 最大并发线程数
///progress  实时进度回调，currentFilePath 当前下载完成的单文件保存路径，isSuccess:是否下载成功，msg：详细信息
///callBack  isAllSuccess:是否全部成功
-(void)downloadFileWithConf:(NSString *)conf rootPath:(NSString *)rootPath patchPath:(NSString *)patchPath threadCount:(NSInteger)threadCount  progress:(nonnull void (^)(NSString * _Nonnull currentFilePath, BOOL isSuccess, NSString * msg))progress callBack:(nonnull void (^)(BOOL))callBack;

///小包文件下载
///conf  要下载的文件列表
///rootPath 文件下载存放路径
///patchPath 文件下载请求路径
///threadCount 最大并发线程数
///progress  实时进度回调，currentFilePath 当前下载完成的单文件保存路径，isSuccess:是否下载成功，msg：详细信息
///callBack  isAllSuccess:是否全部成功
-(void)downloadSubpackFileWithConf:(NSString *)conf rootPath:(NSString *)rootPath patchPath:(NSString *)patchPath threadCount:(NSInteger)threadCount progress:(nonnull void (^)(NSString * _Nonnull currentFilePath, BOOL isSuccess, NSString * msg))progress callBack:(nonnull void (^)(BOOL))callBack;

///修改小包下载状态
///status  Pause：暂停  Loading：继续下载
-(void)changeSubpackStatus:(NSString*)status;


///关闭小包下载纯种
-(void)downloadSubpackFinish;

@end
NS_ASSUME_NONNULL_END
