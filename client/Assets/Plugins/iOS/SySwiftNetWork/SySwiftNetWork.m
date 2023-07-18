//
//  SySwiftNetWork.m
//  TestSwiftDemo
//
//  Created by zhouwenbin on 2023/4/3.
//

#import "SySwiftNetWork.h"


@implementation SySwiftNetWork

+(instancetype)shareInstance{
    
    static SySwiftNetWork *_sySwiftNetWork = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sySwiftNetWork = [[SySwiftNetWork alloc]init];
    });
    
    return _sySwiftNetWork;
    
}



-(void)downloadFileWithConf:(NSString *)conf rootPath:(NSString *)rootPath patchPath:(nonnull NSString *)patchPath threadCount:(NSInteger)threadCount  progress:(nonnull void (^)(NSString * _Nonnull currentFilePath, BOOL isSuccess, NSString * _Nonnull msg))progress callBack:(nonnull void (^)(BOOL))callBack{
    
    DownloadPatchManager *manager = [[DownloadPatchManager alloc] initWithDownloadConf:conf root:rootPath patchPath:patchPath threadCount:threadCount];
    [manager DoInit];
    [manager DownloadThreadWithProgress:^(NSString * _Nonnull fileName, BOOL isSuccess, NSString * msg) {
        
        !progress?:progress(fileName,isSuccess,msg);

    } callBack:^(BOOL isAllSuccess) {
        
        !callBack?:callBack(isAllSuccess);
        
    }];

}

-(void)downloadSubpackFileWithConf:(NSString *)conf rootPath:(NSString *)rootPath patchPath:(nonnull NSString *)patchPath threadCount:(NSInteger)threadCount progress:(nonnull void (^)(NSString * _Nonnull, BOOL, NSString * _Nonnull))progress callBack:(nonnull void (^)(BOOL))callBack{
    
    
    DownloadSubpackageManager *manager = [DownloadSubpackageManager shared];
    [manager setDownloadArgumentsWithDownloadConf:conf root:rootPath patchPath:patchPath threadCount:threadCount];
    [manager DoInit];
    [manager DownloadThreadWithProgress:^(NSString * _Nonnull fileName, BOOL isSuccess, NSString * msg) {
        
        !progress?:progress(fileName,isSuccess,msg);

    } callBack:^(BOOL isAllSuccess) {
        
        !callBack?:callBack(isAllSuccess);
        
    }];
}

-(void)changeSubpackStatus:(NSString *)status{
    
   [[DownloadSubpackageManager shared] ChangeStatusWithStatus:status];
}

- (void)downloadSubpackFinish{
    
    [[DownloadSubpackageManager shared] Clear];
}




@end
