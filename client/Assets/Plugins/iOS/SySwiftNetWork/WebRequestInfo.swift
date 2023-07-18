//
//  WebRequestInfo.swift
//  TestSwift
//
//  Created by huangyuqiu on 2023/3/16.
//

import Foundation

class WebRequestInfo {
    public var path:String?
    public var outputPath:String?
    public var alertTxt:String?
    public var tryCount:Int?
    public var timeout:Int?
    public var useRandom:Bool = false
}

enum DownloadError: Error {
    case ParseError;
    case DownloadError;
    case DownloadPathIsNilError;
    case DownloadMakeDirError;
    case DownloadResponseStatucCodeError;
}
