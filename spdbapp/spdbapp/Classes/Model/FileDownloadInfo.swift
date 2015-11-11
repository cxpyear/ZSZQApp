//
//  FileDownloadInfo.swift
//  ZSApp
//
//  Created by GBTouchG3 on 15/11/6.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class FileDownloadInfo: NSObject {
    var fileid = String()
    
    var fileTitle = String()
    
    var downloadSource = String()
    
    var downloadTask = NSURLSessionDownloadTask()
    
    var taskResumeData = NSData()
    
    var downloadProgress = Float()
    
    var isDownloading = Bool()
    
    var downloadComplete = Bool()
    
    var taskIdentifier = Int()
    
    init(titie: String, source: String){
        self.fileTitle = titie
        self.downloadSource = source
        self.downloadProgress = 0.0
        self.isDownloading = false
        self.downloadComplete = false
        self.taskIdentifier = -1
    }
    
}
