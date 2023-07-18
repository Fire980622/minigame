//
//  HttpRangeRequest.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

class HttpRangeRequest : NSObject, IHttpRequest, URLSessionDataDelegate{
    
    private var totalSize:Double = 0
    private var currLength:Double = 0
    
    private var process:Float = 0
    
    private var requestInfo:WebRequestInfo
    private var asset:VersionAsset
    
    private var bufferSize:Int = 2048
    
    private var failCallBack:DownloadFailBlock?
    private var succCallBack:DownloadSuccBlock?
    
    private var recvSize:Int = 0
    private var oldFileSize:Int64 = 0
    
//    private var receivedData:NSMutableData?
    private var outpath:String?
    private var fileHandle:FileHandle?
    
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
            self.outpath = self.requestInfo.outputPath! + self.urlEncoded(urls: asset.md5)
            self.Dispose()
            
//            path = "https://down.shiyue.com/sygame/software/Android/adt-bundle-windows-x86_64-20140702.zip"
            let url = URL(string: path!)!
            var request = URLRequest(url: url as URL)
            request.httpMethod = "GET"
            request.timeoutInterval = Double(self.requestInfo.timeout!)
            
            // print("========outpath:" + self.outpath!)
            self.oldFileSize = self.FileSize(path: self.outpath!)
            if self.recvSize == 0 {
                self.recvSize = Int(self.oldFileSize)
            }
            if self.oldFileSize > 0 {
                let requestRange = String(format: "bytes=%llu-", self.oldFileSize)
                request.addValue(requestRange, forHTTPHeaderField: "Range")
            }
            
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
    
    func FileSize(path:String) -> Int64 {
        var downloadedBytes: Int64 = 0
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                let fileDict = try fileManager.attributesOfItem(atPath: path)
                downloadedBytes = fileDict[.size] as? Int64 ?? 0
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            let fileUrl = URL(fileURLWithPath: path)
            let dirPath = fileUrl.deletingLastPathComponent().path
            if !fileManager.fileExists(atPath: dirPath, isDirectory: nil) {
                do {
                    try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            /* 文件不存在,创建文件 */
            if !fileManager.createFile(atPath: path as String, contents: nil, attributes: nil) {
                print("create File Error")
            }
        }
        return downloadedBytes
    }
    
    func RenameFile(atPath path: String, toName name: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let newPath = name
            if fileManager.fileExists(atPath: newPath) {
                do {
                    try fileManager.removeItem(atPath: newPath)
                } catch {
                    return false
                }
            }
            do {
                try fileManager.moveItem(atPath: path, toPath: newPath)
                return true
            } catch {
                return false
            }
        }
        // 如果原始文件不存在，则返回 false。
        return false
    }
    
    func urlEncoded(urls:String) -> String {
        return (urls.data(using: .utf8)?.base64EncodedString())!
    }
    
    /* 出现错误,取消请求,通知失败 */
//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        print("=============urlSession=didBecomeInvalidWithError============\(String(describing: error))")
//        self.failCallBack?(self.asset, "download error")
//    }
    
    /* 下载完成 */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Error downloading data: \(error.localizedDescription)")
            self.FailDeal(asset: self.asset, msg: "===range download didCompleteWithError error===:\(error.localizedDescription)")
        } else {
            guard let response = task.response as? HTTPURLResponse else { return }
            if self.fileHandle != nil {
                self.fileHandle!.closeFile()
                self.fileHandle = nil
                self.totalSize = 0
                self.recvSize = 0
            }
            if response.statusCode == 200 || response.statusCode == 206 {
                let contentLen = response.allHeaderFields["Content-Length"]
                let len = Double(String(describing: contentLen!))!
                let fileSize:Int64 = self.FileSize(path: self.outpath!)
                if Int64(len) == fileSize {
                    if !self.RenameFile(atPath: self.outpath!, toName: self.requestInfo.outputPath!) {
                        print("=============rename error")
                        self.FailDeal(asset: self.asset, msg: "===range download rename error===")
                    }
                }
            }
            self.succCallBack?("FINISH")
        }
    }

    /* 接收到数据,将数据存储 */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.recvSize += data.count
        if data.count <= 0 {
            return
        }
        guard let response = dataTask.response as? HTTPURLResponse else { return }
        // print("======recdatasize:\(response.statusCode)")
        if response.statusCode == 200 || response.statusCode == 206 {
            if self.totalSize == 0 {
                let contentLen = response.allHeaderFields["Content-Length"]
                self.totalSize = Double(String(describing: contentLen!))!
            }
            
            if self.fileHandle == nil {
                do {
                    self.fileHandle = try FileHandle(forUpdating: URL(fileURLWithPath: self.outpath!))
                } catch let error {
                    print("===new fileHandle error:\(error.localizedDescription)")
                }
            }
            self.fileHandle!.seekToEndOfFile()
            self.fileHandle!.write(data)
        }
    }
}

