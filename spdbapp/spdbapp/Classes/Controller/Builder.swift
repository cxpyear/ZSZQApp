//
//  Builder.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/14.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class Builder: NSObject {
    
    override init() {
        super.init()
        Poller().start(self, method: "getCurrentPerTime:", timerInter: 10.0)
    }
    
    
    func isAllFileDownloaded() -> Bool{
        var count = current.sources.count
        var manager = NSFileManager.defaultManager()
        
        for var i = 0 ; i < count; i++ {
            if let source = GBSource(keyValues: current.sources[i]){
                var id  = source.id
                var path = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(id).pdf")
                
                if !manager.fileExistsAtPath(path){
                    return false
                }
            }
        }
        return true
    }
    
    func getCurrentPerTime(timer: NSTimer){
        
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request , response , data , error ) -> Void in
            if error != nil{
                println("get current error = \(error)")
                
                if self.isAllFileDownloaded() == false {
//                    NSNotificationCenter.defaultCenter().postNotificationName(FileNeedDownloadNotification, object: nil)
                }
                return
            }else{
                
                //判断当前会议是否和本地保存的会议信息一致。一致则返回。
                if let dataResult: AnyObject = data{
                    if let dataValue = NSJSONSerialization.dataWithJSONObject(dataResult, options: NSJSONWritingOptions.allZeros, error: nil){
                        var isSameData = isSameJsonFileExist(dataValue, jsonFilePath)
                        if isSameData == true{
                            
                            if self.isAllFileDownloaded() == true{
                                return
                            }else{
                                println("isDownloading =============== \(isDownloading)")
                                if isDownloading == false{
                                    isDownloading = true
                                    
                                    DownLoadManager()
                                }
                            }
                        }
                            
                            //当前会议和本地保存的会议信息不一致
                        else{
                            if let result = GBCurrent(keyValues: dataResult){
                                current = result
                                
                                GBNotificationCenter().postNotificationName(CurrentDidChangedNotification, object: nil, userInfo: [CurrentDidChangedName: current])
                                
                                println("post current change notification")
                                
                                //如果当前会议不为空
                                //1.通知其他界面回到主界面刷新
                                //2.下载所有的json数据和文件数据
                                if current.id.isEmpty == false{
                                    DownLoadManager()
                                }
                                    
                                    //如果当前会议为空
                                    //1.通知其他界面回到主界面刷新
                                    //2.下载所有的json数据和文件数据
                                else{
                                    
                                    downloadlist.removeAll(keepCapacity: false)
                                    DeleteManager().deleteAllFiles()
                                }
                                
                                
                            }
                        }
                    }
                    
                }
            }
        }
    }

    
    
    //Create Meeting online
//    func CreateMeeting() -> GBMeeting {
//        
//        var current = GBMeeting()
//        var url = NSURL(string: server.meetingServiceUrl)
//        
//        var isNeedResign = true
//        
//        var data = NSData(contentsOfURL: url!)
//        if(data != nil){
//            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
//            
////             println("json ============ \(json)")
//            
//            current.id = json["id"] as! String
//            current.name = json["name"] as! String
    
            
            
//            var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/LoginInfo.plist")
//            print("path = \(filePath)")
//            var manager = NSFileManager.defaultManager()
//            var fileDic = NSMutableDictionary(capacity: 2)
//            //如果当前不存在该文件，则创建该文件，并且创建两个字段
//            if !manager.fileExistsAtPath(filePath){
//                bNeedLogin = true
//                manager.createFileAtPath(filePath, contents: nil, attributes: nil)
//                
//                fileDic.setObject(current.id, forKey: "meetingId")
//                println("id = \(current.id)")
//                fileDic.setObject(false, forKey: "isLogin")
//                fileDic.writeToFile(filePath, atomically: true)
//                
//            }else{
//                fileDic = NSMutableDictionary(contentsOfFile: filePath)!
//                var oldId = fileDic.objectForKey("meetingId") as? String
//                var isLogin = fileDic.objectForKey("isLogin")?.boolValue
//                
//                println("islogin = \(fileDic.count)")
//                if ((isLogin == true) && (oldId == current.id)){
//                    bNeedLogin = false
//                }else{
//                    bNeedLogin = true
//                }
//            }
            
            
        
//            var readData = NSData(contentsOfFile: filePath)
//            if readData?.length > 0{
//                var oldId = NSString(data: readData!, encoding: NSUTF8StringEncoding)
//                if oldId == current.id{
//                    
//                }
//                temp.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
//            }
//            
//            var name = current.id
//            var b = name.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            
            
//        }
//        return current
//    }


    //Create Meeting offline
//    func LocalCreateMeeting() -> GBMeeting {
//        
//        var current = GBMeeting()
//        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
//        var filemanager = NSFileManager.defaultManager()
//        
//        if filemanager.fileExistsAtPath(localJSONPath){
//            var jsonLocal = filemanager.contentsAtPath(localJSONPath)
//            var json: AnyObject = NSJSONSerialization.JSONObjectWithData(jsonLocal!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
//            
//           
//            current.id = json["id"] as! String
//            current.name = json["name"] as! String
//            println(current.name)
//        }
//        return current
//    }
//    
//    func getTotalMembers() -> [GBMember]{
//        var allembers = [GBMember]()
//        
//        var url = NSURL(string: server.meetingServiceUrl)
//        var data = NSData(contentsOfURL: url!)
//        
//        if(data != nil){
//            var jsonData: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
//            var json = JSON(jsonData)
//            
//            println("json ===== \(json)")
//            
//            if let members = json["member"].array{
//                for var i = 0 ; i < members.count ;i++ {
//                    var member = GBMember()
//                    member.id = members[i]["id"].stringValue
//                    member.username = members[i]["username"].stringValue
//                    member.name = members[i]["name"].stringValue
//                    member.password = members[i]["password"].stringValue
//                    allembers.append(member)
//                }
//            }
//        }
//        
//        println("allembers = \(allembers.count)")
//        return allembers
//    }
}


