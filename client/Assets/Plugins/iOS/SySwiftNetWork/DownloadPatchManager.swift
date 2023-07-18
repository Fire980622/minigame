//
//  DownloadPatchManager.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

@objc public class DownloadPatchManager:NSObject {
    
    private var downloadConf: String
    private var reader:DownloadConfReader?
    private var root: String
    private var patchPath: String
    
    private var threadCount:Int = 5
    private var tryCount:Int = 3
    private var timeOut:Int = 15
    private var filaPathMap:[String:String] = [String:String]()
    var isAllSuc = true
   
    @objc public init(downloadConf: String, root: String, patchPath:String, threadCount:Int) {
        self.root = root
        self.patchPath = patchPath
        self.downloadConf = downloadConf
        if threadCount >= 1 && threadCount <= 20 {
            self.threadCount = threadCount
        }
    }
    
    @objc  public func DoInit() -> Void {
        if (self.reader == nil) {
            self.reader = DownloadConfReader(path: self.downloadConf)
        }
    }
    
    @objc public func DownloadThread(progress:@escaping (NSString,Bool,NSString) ->Void,callBack:@escaping (Bool) ->Void) -> Void {
        //记录请求开始时间
        let startTime = DispatchTime.now()
        //创建异并发队列
        let queue = DispatchQueue(label: "com.label.concurrent", attributes: .concurrent)
        //线程组，所有任务线程加入线程组中，接收最终结果
        let group = DispatchGroup()
        //记录是否全部成功
        self.isAllSuc = true
        let lsize:Int = 102 * 1024

        for _ in 1 ... self.threadCount {
            //创建信号量，确保每个线程只有一个网络请求在跑
            let semaphore = DispatchSemaphore(value: 0)
            let workItem = DispatchWorkItem {
                var asset:VersionAsset? = self.reader?.SyncPoll()
                var running:Bool = false
                var request:IHttpRequest?
                var requestRange:IHttpRequest?
                let failBlock:DownloadFailBlock = {asset2, msg in
//                    print("failbloack====:" + msg)
                    self.isAllSuc = false
                    progress(asset2.path as NSString, false , msg as NSString)
                    asset = self.reader?.SyncPoll()
                    running = false
                    semaphore.signal()
                }
                let succBlock:DownloadSuccBlock = {msg in
//                    print("succBlock====:" + msg + " threadcount:\(self.threadCount)")
//                    print("currentThread: \(Thread.current)")
                    progress(asset!.path as NSString, true , msg as NSString)
                    asset = self.reader?.SyncPoll()
                    running = false
                    semaphore.signal()
                }
                
                while true {
                    if asset != nil && !running {
                        let downPath = self.patchPath + "/" + asset!.patchVersion + "/" + asset!.path
                        let savePath = self.root + "/" + asset!.path
                        let webRequest:WebRequestInfo = WebRequestInfo()
                        webRequest.path = downPath
                        webRequest.outputPath = savePath
                        webRequest.tryCount = self.tryCount
                        webRequest.timeout = self.timeOut
                        if(request == nil){
                            request = HttpDownloadRequest(requestInfo: webRequest, asset: asset!)
                            requestRange = HttpRangeRequest(requestInfo: webRequest, asset: asset!)
                        }
                        if (Int(asset!.size)! > lsize) {
                            running = true
                            requestRange?.Update(requestInfo: webRequest, asset: asset!, failCallBack: failBlock, succCallBack: succBlock)
                            requestRange!.Get()
                        } else {
                            running = true
                            request?.Update(requestInfo: webRequest, asset: asset!, failCallBack: failBlock, succCallBack: succBlock)
                            request!.Get()
                        }
                        semaphore.wait()
                    } else if asset != nil && running {
                        print("===========sleep you can't see me=======")
//                        Thread.sleep(forTimeInterval: 0.01)
                    } else {
                        let endTime = DispatchTime.now()
                        let timeInterval = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                        let timeIntervalInSeconds = Double(timeInterval) / 1_000_000_000
                        print("==========patch=====代码执行时间：\(timeIntervalInSeconds) 秒")
                        break;
                    }
                }
            }
            //创建异步并发线程，并加入到线程组中
            queue.async(group: group, execute: workItem)
        }
        
        group.notify(queue: queue) {
            print("所有线程请求完成")
            callBack(self.isAllSuc)
        }
    }
    
}
