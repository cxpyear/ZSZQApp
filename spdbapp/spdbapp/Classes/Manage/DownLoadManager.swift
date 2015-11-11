//
//  DownLoadFiles.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/19.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire



//class DownloadFile: NSObject {
//    var filename: String = ""
//    var filebar: Float = 0
//}
//var downloadlist:[DownloadFile] = []

//var downloadFileList = [FileDownloadInfo]()

class DownloadFile: NSObject {
    var filebar: Float = 0
    var fileid: String = ""
    var fileResumeData: NSData = NSData()
    var isdownloading = Bool()
}


var downloadlist:[DownloadFile] = []

var isDownloading = Bool()

class DownLoadManager: NSObject {
    
//    var session = NSURLSession()
//    var docDirectoryURL = NSURL()
    
    override init(){
        super.init()
        
        downloadJSON()
        downloadFile()
        
//        var urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
//        self.docDirectoryURL = urls.first as! NSURL
        
        
//        var sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.DownloadDemo")
//        //("com.DownloadDemo")
//        //[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.DownloadDemo"];
//        sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
//        
//        self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
            //[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        
//        initDownloadFileList()
    
    }
    
    
    func downloadJSON(){
        
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (request , response , data , error ) -> Void in
            if error != nil{
                println("get json error = \(error)")
                return
            }else{
                //                println("json data = \(jsonFilePath)")
                
                if let dataValue: AnyObject = data{
                    if let writeData = NSJSONSerialization.dataWithJSONObject(dataValue, options: NSJSONWritingOptions.allZeros, error: nil){
                        var isSameJsonData = isSameJsonFileExist(writeData, jsonFilePath)
                        if isSameJsonData == true{
                            return
                        }else{
                            var manager = NSFileManager.defaultManager()
                            if !manager.fileExistsAtPath(jsonFilePath){
                                manager.createFileAtPath(jsonFilePath, contents: nil , attributes: nil )
                            }
                            dataWriteToFile(writeData, jsonFilePath)
                        }
                    }
                }
            }
        })
    }
    
    func downloadFile(){
        var sources = current.sources
        var meetingid = current.id
        
        
        for var i = 0 ; i < sources.count ; i++ {
            var source = GBSource(keyValues: sources[i])
            var fileid = source.id
            var filename = source.name
            
            var downloadCurrentFile = DownloadFile()
            downloadCurrentFile.fileid = fileid
            
            var isfind:Bool = false
            
            if downloadlist.count==0{
                downloadlist.append(downloadCurrentFile)
            }
            else {
                for var i = 0; i < downloadlist.count ; ++i {
                    if fileid == downloadlist[i].fileid {
                        isfind = true
                        downloadCurrentFile = downloadlist[i]
                        break
                    }
                }
                if !isfind {
                    downloadCurrentFile.filebar = 0
                    downloadlist.append(downloadCurrentFile)
                }
            }
            
            //判断当前沙盒中是否存在对应的pdf文件，若存在，则直接返回，否则下载该文件。
            var b = isSameFileExist(fileid)
            if b == true{
                println("\(filename)已存在")
                downloadCurrentFile.filebar = 1
                continue
            }
            
            var filepath = server.downloadFileUrl + "gbtouch/meetings/\(meetingid)/\(fileid).pdf"
            var getPDFURL = NSURL(string: filepath)
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            
            
            var res: Alamofire.Request?
            
            if downloadlist[i].fileResumeData.length > 0 && downloadlist[i].isdownloading == false{
                res = Alamofire.download(resumeData: downloadlist[i].fileResumeData, destination)
                println("resuming=======================")
            }else{
                res = Alamofire.download(.GET, getPDFURL!, destination)
                println("downloading=======================")
            }
            
            res!.progress(closure: { (_ , totalBytesRead, totalBytesExpectedToRead) -> Void in
                var processbar: Float = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
                
                for var i = 0 ; i < downloadlist.count ; i++ {
                    if downloadlist[i].fileid == downloadCurrentFile.fileid{
                        if processbar > downloadCurrentFile.filebar{
                            
                            downloadCurrentFile.filebar = processbar
                            downloadCurrentFile.isdownloading = true
                            //                            println("i = \(i) bar = \(processbar)")
                            
                            if processbar == 1{
                                println("\(filename)下载完成")
                            }
                        }
                    }
                }
                
            }).response({ (_ , _ , _ , error ) -> Void in
                
                for var i = 0 ; i < downloadlist.count ; i++ {
                    if downloadlist[i].fileid == downloadCurrentFile.fileid{
                        
                        if error != nil{
                            if let errInfo = error!.userInfo{
                                if let resumeInfo: AnyObject = errInfo[NSURLSessionDownloadTaskResumeData]{
                                    if let resumeD = resumeInfo as? NSData{
                                        downloadCurrentFile.fileResumeData = resumeD
                                        downloadCurrentFile.isdownloading = false
                                    }
                                }
                            }
                            isDownloading = false
                        }else{
                            isDownloading = true
                        }
                    }
                }
            })
        }
    }


    
//    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
//        var appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        self.session.getTasksWithCompletionHandler { (dataTask , uploadTask , downloadTask) -> Void in
//            if downloadTask.count == 0{
//                if appdelegate.backgroundTransferCompletionHandler != nil{
//                    var completionHandler: (() -> Void)? = appdelegate.backgroundTransferCompletionHandler
//                    appdelegate.backgroundTransferCompletionHandler = nil
//                    
//                }
//            }
//        }
//    }
//    
//    func initDownloadFileList(){
//        var meetingid = current.id
//        for var i = 0 ; i < current.sources.count ; i++ {
//            var s = GBSource(keyValues: current.sources[i])
//            var sid = s.id
//            
//            var isFileExist = isSamePDFFile(sid)
//            if isFileExist == true{
//                continue
//            }
//            
//            var fileSource = server.downloadFileUrl + "gbtouch/meetings/\(meetingid)/\(sid).pdf"
//            var fdi = FileDownloadInfo(titie: s.name, source: fileSource)
//            
//            if downloadFileList.count > 0{
//                for var k = 0 ; k < downloadFileList.count ; k++ {
//                    if downloadFileList[k].fileid == sid{
//                        break
//                    }else{
//                        downloadFileList.append(fdi)
//                    }
//                }
//            }else{
//                downloadFileList.append(fdi)
//            }
//            
//            DownloadFile(fdi)
//        }
//    }
//    
//    
//    func DownloadFile(fdi: FileDownloadInfo){
//        if (fdi.isDownloading == false) {
//            if (fdi.taskIdentifier == -1) {
//                fdi.downloadTask = self.session.downloadTaskWithURL(NSURL(string: fdi.downloadSource)!)
//            }else{
//                fdi.downloadTask = self.session.downloadTaskWithResumeData(fdi.taskResumeData)
//            }
//            
//            fdi.isDownloading = true;
//            fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
//            fdi.downloadTask.resume()
//        }
//    }
//
//    
//    func getFileDownloadInfoIndexWithTaskIdentifier(taskIdentifier: Int) -> Int{
//        var index = 0
//        for var i = 0 ; i < downloadFileList.count ; i++ {
//            if downloadFileList[i].taskIdentifier == taskIdentifier{
//                index = i;
//                break;
//            }
//        }
//        return index
//    }
//
//
//    
//    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown{
//            NSLog("Unknown transfer size");
//        }else{
//            NSLog("taskIdentifier = %lu", downloadTask.taskIdentifier)
//            var index = self.getFileDownloadInfoIndexWithTaskIdentifier(downloadTask.taskIdentifier)
//            var fdi = downloadFileList[index]
//            
//            fdi.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//        }
//    }
//    
//    
//    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
//        var error = NSErrorPointer()
//        var fileManager = NSFileManager.defaultManager()
//        if let destinationFilename = downloadTask.originalRequest.URL?.lastPathComponent{
//            var destinationURL = self.docDirectoryURL.URLByAppendingPathComponent(destinationFilename)
//            
//            if let path = destinationURL.path{
//                if fileManager.fileExistsAtPath(path){
//                    fileManager.removeItemAtURL(destinationURL, error: nil)
//                }
//                
//                var success = fileManager.copyItemAtURL(location, toURL: destinationURL, error: error)
//                var index = getFileDownloadInfoIndexWithTaskIdentifier(downloadTask.taskIdentifier)
//                var fdi = downloadFileList[index]
//                fdi.isDownloading = false
//                fdi.downloadComplete = true
//                fdi.taskIdentifier = -1
//                
//            }else{
//                NSLog("unable to copy items ,Error = %@", error)
//            }
//            
//        }
//        
//    }
    
}

    

    
    
    
    
//    dynamic var downloadCurrentFile = DownloadFile()
    
    //判断当前文件夹是否存在jsondata数据，如果不存在，则继续进入下面的步骤
    //如果存在该数据，则判断当前json与本地jsonlocal是否一致，如果一致，则打印 json数据信息已经存在，return
//    class func isSameJSONData(jsondata: NSData) -> Bool {
//        
//        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
//        var filemanager = NSFileManager.defaultManager()
//        
//        if filemanager.fileExistsAtPath(localJSONPath){
//            let jsonLocal = filemanager.contentsAtPath(localJSONPath)
//            
//            if jsonLocal == jsondata {
//                //println("json数据信息已经存在")
//                return true
//            }
//            return false
//        }
//        return false
//    }
    

    
//    class func isStart(bool: Bool){
//        if bool == true{
////            downLoadAllFile()
//            downLoadJSON()
//        }
//    }
    
    
    //-> (currentSeq: Int, totalCount: Int) -> (name: String, downSize: Int, allSize: Int)
//    class func downLoadAllFile(){
//        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
//            if(err != nil){
//                NSLog("download allsourcefile error ==== %@", err!)
//                return
//            }
//            
//            let json = JSON(data!)
//            var meetingid = json["id"].stringValue
//            
//
//            
//            if let agendasInfo = json["agenda"].array
//            {
//                //获取所有的议程信息
//                for var i = 0 ;i < agendasInfo.count ; i++ {
//                    var agendas = agendasInfo[i]
//                    
//                    if let fileSourceInfo = agendas["source"].array{
//                        for var j = 0 ; j < fileSourceInfo.count ; j++ {
//                            
////                        var downloadCurrent = DownloadFile()
//                            
//                        var fileid = fileSourceInfo[j].stringValue
//                        var filename = String()
//
//                        //根据source的id去寻找对应的name
//                        if let sources = json["source"].array{
//                            for var k = 0 ; k < sources.count ; k++ {
//                                if fileid == sources[k]["id"].stringValue{
//                                    filename = sources[k]["name"].stringValue
//                                }
//                            }
//                        }
//                        var isfind:Bool = false
//                        var downloadCurrentFile = DownloadFile()
//                        downloadCurrentFile.filename = filename
//                        downloadCurrentFile.filebar = 0
//                            if downloadlist.count==0{
//                                downloadlist.append(downloadCurrentFile)
//                            }else {
//                                for var i = 0; i < downloadlist.count  ; ++i {
//                                    if filename == downloadlist[i].filename {
//                                        isfind = true
//                                    }
//                                }
//                                if !isfind {
//                                    downloadlist.append(downloadCurrentFile)
//                                }
//                            }
////                            println("count========\(downloadlist.count)")
//                        //http://192.168.16.141:10086/gbtouch/meetings/73c000fa-2f5b-44ef-9dff-addba27d8e18/6d1f55b9-9773-4932-a3c1-8fcc88b8ead1.pdf
//                            
//                        var filepath = server.downloadFileUrl + "gbtouch/meetings/\(meetingid)/\(fileid).pdf"
//                        var getPDFURL = NSURL(string: filepath)
//                            
//                        let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
//                            (temporaryURL, response) in
//                            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as? NSURL{
//                                var filenameURL = directoryURL.URLByAppendingPathComponent("\(filename)")
//                                return filenameURL
//                            }
//                            return temporaryURL
//                        }
//        
////                        println("file name = \(filename)")
//                        //判断../Documents是否存在当前filename为名的文件，如果存在，则返回；如不存在，则下载文件
//                        var b = self.isSamePDFFile(filename)
//                        if b == false{
//                            Alamofire.download(.GET, getPDFURL!, headers: nil, destination: destination).progress {
//                                (_, totalBytesRead, totalBytesExpectedToRead) in
//                                dispatch_async(dispatch_get_main_queue()) {
//                                    
//                                    downloadCurrentFile.filename = filename
//                                    var processbar: Float = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
//                                    downloadCurrentFile.filebar = processbar
////                                    println("filename = \(downloadCurrentFile.filename)      filebar = \(downloadCurrentFile.filebar)")
//                                    for var i = 0; i < downloadlist.count  ; ++i {
//                                        if filename == downloadlist[i].filename {
//                                            if processbar > downloadlist[i].filebar {
//                                                downloadlist[i].filebar = processbar
//                                            }
//                                        }
//                                    }
////                                    println("正在下载\(filename)，文件下载进度为\(processbar)")
//                                    if totalBytesRead == totalBytesExpectedToRead {
//                                        println("\(filename)   下载成功")
//                                    }
//                                }
//                            }
//                        }else if b == true{
//                            println("\(filename)文件已存在")
//                        }
//                    }
//                }
//              }
//            }
//        }
//    }

    
//    class func isFileDownload(name: String) -> Bool{
//        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(name)")
//        var manager = NSFileManager.defaultManager()
//        if manager.fileExistsAtPath(filepath){
//            return true
//        }else{
//            return false
//        }
//    }
    
    
    //下载json数据到本地并保存
//    class func downLoadJSON(){
//        
//        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
//            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
//            
//            //println("\(jsonFilePath)")
//            
//            if(err != nil){
//                println("下载当前json出错，error ===== \(err)")
//                return
//            }
//            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
//            
//            //如果当前json和服务器上的json数据不一样，则保存。保存成功提示：当前json保存成功，否则提示：当前json保存失败。
//            var bool = self.isSameJSONData(jsondata!)
//            if !bool{
//                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
//                if (b! == true) {
//                    NSLog("当前json保存成功")
//                }
//                else{
//                    NSLog("当前json保存失败")
//                }
//                
//            }
//            
//            var manager = NSFileManager.defaultManager()
//            if !manager.fileExistsAtPath(jsonFilePath){
//                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
//                if b{
//                    println("创建json成功")
//                }
//            }
//        }
//    }
    
//}
//}