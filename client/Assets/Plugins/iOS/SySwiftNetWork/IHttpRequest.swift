//
//  IHttpRequest.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/15.
//

import Foundation

protocol IHttpRequest {
    func Get() -> Void
    func Dispose() -> Void
    func Update(requestInfo:WebRequestInfo, asset:VersionAsset, failCallBack:@escaping DownloadFailBlock, succCallBack:@escaping DownloadSuccBlock) -> Void
}
