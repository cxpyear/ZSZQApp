//
//  Server.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation

class Server: NSObject {
    var boxServiceUrl = String()
    var meetingServiceUrl = String()
    var fileServiceUrl = String()
    var heartBeatServiceUrl = String()
    var loginServiceUrl = String()
    var downloadFileUrl = String()
    
//    var memberServiceUrl = String()
    
    override init(){
        super.init()
        
        var url = getInitialIP()

        meetingServiceUrl = "http://" + url + ":18080/v1/current"
        heartBeatServiceUrl = "http://" + url + ":18080/v1/heartbeat"
        loginServiceUrl = "http://" + url + ":18080/v1/login"
        downloadFileUrl = "http://" + url + ":10086/"
    }
    
    func getInitialIP() -> String {
        var result = String()
        
        var defaults = NSUserDefaults.standardUserDefaults()
        var value = defaults.stringForKey("txtBoxURL")
        
        println("url = \(value)")
        
        if let v = value{
            result = v
        }else{
            result = "192.168.22.56"
            defaults.setObject(result, forKey: "txtBoxURL")
            defaults.synchronize()
        }
        
        return result


        
        //设置界面显示本机id
//        var lblShowID = defaults.stringForKey("lbl_showID")
//        var idValue = GBNetwork.getMacId()
//        defaults.setObject(idValue, forKey: "lbl_showID")
//        defaults.synchronize()
        
        var versionValue = "1.1"
        defaults.setObject(versionValue, forKey: "lbl_Version")
        defaults.synchronize()
        
    }
    
    
//    func clearHistoryInfo(type: String){
//        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
//        var manager = NSFileManager.defaultManager()
//        if let filelist = manager.contentsOfDirectoryAtPath(filepath, error: nil){
//            
//            println("file = \(filelist)")
//            
//            var count = filelist.count
//            for (var i = 0 ; i < count ; i++ ){
//                if filelist[i].pathExtension == type{
//                    var docpath = filepath.stringByAppendingPathComponent("\(filelist[i])")
//                    var b = manager.removeItemAtPath(docpath, error: nil)
//                    if b{
//                        println("\(filelist[i])文件删除成功")
//                    }
//                }
//            }
//        }
//    }
    
}