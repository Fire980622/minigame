//
//  HttpNormalRequest.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

class HttpDownloadRequest : NSObject, IHttpRequest, URLSessionDownloadDelegate {
    
    
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
    
    
    init(requestInfo:WebRequestInfo, asset:VersionAsset) {
        self.requestInfo = requestInfo
        self.asset = asset
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
            
            let dataTask = session.downloadTask(with: request)
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
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            guard let response = downloadTask.response as? HTTPURLResponse else { return }
            if response.statusCode == 200 || response.statusCode == 206 {
                // 将下载完成的文件移动到指定目录
                let fileManager = FileManager.default
                let filePath:String = self.requestInfo.outputPath!
                if fileManager.fileExists(atPath: filePath) {
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    } catch {
                        print("===deletefileerror===\(error.localizedDescription)")
                        throw error
                    }
                }
                try fileManager.moveItem(at: location, to: URL(fileURLWithPath: self.requestInfo.outputPath!))
            } else {
                print("===download error===:\(response.statusCode)")
                throw DownloadError.DownloadResponseStatucCodeError
            }
        } catch {
            print("save file error: \(error.localizedDescription)")
//            self.FailDeal(asset: self.asset, msg: "fileManager.moveItem Error:\(error.localizedDescription)")
        }
    }
    
    /* 下载完成 */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("===didCompleteWithError Error Is Not nil: \(error!.localizedDescription)")
            self.FailDeal(asset: self.asset, msg: "Error during download: \(error!.localizedDescription)")
            return
        } else {
            guard let response = task.response as? HTTPURLResponse else { return }
            if response.statusCode == 200 || response.statusCode == 206 {
//                DispatchQueue.main.async {
//                    self.succCallBack?(self.requestInfo.path!)
//                }
                self.succCallBack?(self.requestInfo.path!)
            } else {
                print("===didCompleteWithError StatusCode Error:\(response.statusCode)")
                self.FailDeal(asset: self.asset, msg: "Error during download: \(DownloadError.DownloadResponseStatucCodeError)")
                return
            }
        }
    }
}

