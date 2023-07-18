//
//  HttpNormalRequest.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

typealias DownloadFailBlock = (VersionAsset, String) -> Void
typealias DownloadSuccBlock = (String) -> Void

class HttpNormalRequest : NSObject, IHttpRequest, URLSessionDataDelegate{
    
    private var process:Float = 0
    
    private var requestInfo:WebRequestInfo
    private var asset:VersionAsset
    
    private var bufferSize:Int = 2048
    
    private var failCallBack:DownloadFailBlock?
    private var succCallBack:DownloadSuccBlock?
    
    private var recvSize:Int = 0
    
    private var receivedData:NSMutableData?
    
    private var session:URLSession?
    
    public func SetBufferSize(size:Int) -> Void {
        self.bufferSize = size
    }
    
    
    init(requestInfo:WebRequestInfo, asset:VersionAsset, failCallBack:@escaping DownloadFailBlock, succCallBack:@escaping DownloadSuccBlock) {
        self.requestInfo = requestInfo
        self.asset = asset
        self.failCallBack = failCallBack
        self.succCallBack = succCallBack
    }
    
    func Update(requestInfo:WebRequestInfo, asset:VersionAsset, failCallBack:@escaping DownloadFailBlock, succCallBack:@escaping DownloadSuccBlock) {
        self.requestInfo = requestInfo
        self.asset = asset
        self.failCallBack = failCallBack
        self.succCallBack = succCallBack
    }
    
    func Get() {
        do {
            var path = self.requestInfo.path
            if self.requestInfo.useRandom {
                let num = Int.random(in: 1...1000)
                if let pathtmp = path {
                    path = pathtmp + "?random=\(num)"
                } else {
                    throw DownloadError.DownloadPathIsNilError
                }
            }
            self.Dispose()
            if !self.MakeDir(path: self.requestInfo.outputPath!) {
                throw DownloadError.DownloadMakeDirError
            }
            
            let url = URL(string: path!)!
            var request = URLRequest(url: url as URL)
            request.httpMethod = "GET"
            request.timeoutInterval = Double(self.requestInfo.timeout!)
        
            if (self.session == nil) {
                let urlconfig = URLSessionConfiguration.default
                urlconfig.timeoutIntervalForRequest = Double(self.requestInfo.timeout!)
//                urlconfig.timeoutIntervalForResource = Double(self.requestInfo.timeout!)
                self.session =  URLSession(configuration: urlconfig, delegate: self, delegateQueue: nil)
            }
            let session = self.session!
            
            let dataTask = session.dataTask(with: request)
            dataTask.resume()
//            print("resume finish")
        } catch {
            print("HttpNormalRequestError:\(error)")
            self.FailDeal(asset: self.asset, msg: "HttpNormalRequestError\(error)")
        }
    }
    
    func FailDeal(asset:VersionAsset, msg:String) -> Void {
        self.Dispose()
        print("FailDeal:path:\(asset.path) msg:\(msg) tryCount:\(self.requestInfo.tryCount!)")
        self.requestInfo.tryCount = self.requestInfo.tryCount! - 1
        if (self.requestInfo.tryCount! <= 0) {
            self.failCallBack?(asset, self.requestInfo.path!)
        } else {
            self.Get()
        }
    }
    
    func Dispose() {
    }
    
    func MakeDir(path:String) -> Bool {
        let fileManager = FileManager.default
        let fileUrl = URL(fileURLWithPath: path)
        let dirPath = fileUrl.deletingLastPathComponent().path
        if !fileManager.fileExists(atPath: dirPath, isDirectory: nil) {
            do {
                try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        }
        return true
    }
    
    /* 出现错误,取消请求,通知失败 */
//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        if error != nil {
//            self.FailDeal(asset: self.asset, msg: "===didBecomeInvalidWithError===:\(error!.localizedDescription)")
//        }
//    }
    
    /* 下载完成 */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error downloading data: \(error.localizedDescription)")
            self.FailDeal(asset: self.asset, msg: "===Data didCompleteWithError===:\(error.localizedDescription)")
        } else {
            guard let response = task.response as? HTTPURLResponse else {
                return
            }
//            print("=============continue======\(response.statusCode) \(type(of: task.response)) \(self.receivedData!.count)")
            if response.statusCode == 200 || response.statusCode == 206 {
                if self.receivedData != nil && self.receivedData!.count > 0 {
                    do {
                        try self.receivedData!.write(to: URL(fileURLWithPath: self.requestInfo.outputPath!))
                        self.receivedData = nil
                        self.recvSize = 0
                    } catch {
                        print("write data to file error")
                        self.FailDeal(asset: self.asset, msg: "===Data didCompleteWithError===:write data to file error")
                    }
                } else {
                    print("===============self.resceivedData is nill\(self.asset.path)")
                }
                self.succCallBack?(self.requestInfo.path!)
            } else {
                self.FailDeal(asset: self.asset, msg: "===Data didCompleteWithError===:response statusCode error")
            }
        }
    }

    /* 接收到数据,将数据存储 */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.recvSize += data.count
        guard let response = dataTask.response as? HTTPURLResponse else { return }
        if self.receivedData == nil {
            self.receivedData = NSMutableData()
        }
        if response.statusCode == 200 || response.statusCode == 206 {
            self.receivedData!.append(data)
        }
    }
}
