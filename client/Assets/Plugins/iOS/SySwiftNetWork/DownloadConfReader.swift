//
//  DownloadConfReader.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

class DownloadConfReader {
    
    private var list:Queue<VersionAsset>
    private let listLock = NSLock()

    init(path:String) {
        list = Queue<VersionAsset>()
        self.Parse(path:path)
    }
    
    private func Parse(path: String) -> Void {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let content = try String(contentsOf: fileUrl, encoding: .utf8)
            let lines = content.split(separator: "\n")
            for line in lines {
//                print("line:\(line)")
                let items = line.trimmingCharacters(in: .whitespaces).components(separatedBy: "<#>")
                if items.count != 4 {
                    continue
                }
                let asset = VersionAsset(path:items[0], size:items[2], patchVersion:items[1], md5:items[3])
                list.enqueue(asset)
                // print("/\(asset.patchVersion)/\(asset.path) \(asset.size) \(asset.md5)")
            }
            print("ios conf list size:\(list.count)")
        } catch _ {
            print("Download Config Parse Error")
        }
    }
    
    public func GetSize() -> Int {
        var count = 0
        listLock.lock()
        count = list.count
        listLock.unlock()
        return count
    }
    
    public func SyncPoll() -> VersionAsset? {
        var asset:VersionAsset?
        listLock.lock()
        if !list.isEmpty {
            asset = list.dequeue()
        }
        listLock.unlock()
        return asset
    }
    
    public func SyncAdd(asset:VersionAsset) -> Void {
        listLock.lock()
        list.enqueue(asset)
        listLock.unlock()
    }
    
    public func SyncClear() -> Void {
        if list.isEmpty {
            return
        }
        listLock.lock()
        list.clear()
        list = Queue<VersionAsset>()
        listLock.unlock()
    }
}

class VersionAsset {
    private(set) var path: String
    private(set) var size: String
    private(set) var patchVersion: String
    private(set) var md5: String
    
    init(path: String, size: String, patchVersion: String, md5: String) {
        self.path = path
        self.size = size
        self.patchVersion = patchVersion
        self.md5 = md5
    }
}

public struct Queue<T> {
    fileprivate var array = [T]()
    public var isEmpty: Bool {
        return array.isEmpty
    }
    public var count: Int {
        return array.count
    }
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    public mutating func dequeue() -> T? {
        if isEmpty {
           return nil
        } else {
           return array.removeFirst()
        }
     }
    public mutating func clear() -> Void {
        array.removeAll()
    }
        
    public var front: T? {
        return array.first
    }
}
