//
//  AppManager.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation
import Alamofire

class Poller {
    var timer: NSTimer?
    
    func start(obj: NSObject, method: Selector,timerInter: Double) {
        stop()
        
        timer = NSTimer(timeInterval: timerInter, target: obj, selector: method , userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    func stop() {
        if (isRun()){
            timer?.invalidate()
        }
    }
    
    func isRun() -> Bool{
        return (timer != nil && timer?.valid != nil)
    }
}


class AppManager : NSObject {
    dynamic var netConnect: Bool = false
    dynamic var wifiConnect : Bool = false
    
    var meetingName = String()

    var reqBoxURL: String?
    var count = 0
    
    var local = GBBox()
    
    override init(){
        super.init()
        
        self.netConnect = false
        self.wifiConnect = false
        
        starttimer()
        startWifiCheckTimer()
        
//        local = createBox()
        
//        totalMembers = builder.getTotalMembers()
     }
    
    /**
    每隔3s轮询检测当前wifi连接状态
    */
    func startWifiCheckTimer(){
        Poller().start(self, method: "checkWifiConnect:", timerInter: 3.0)
    }
    func checkWifiConnect(timer: NSTimer){
        if Reachability.reachabilityForInternetConnection().currentReachabilityStatus != Reachability.NetworkStatus.NotReachable{
            self.wifiConnect = true
        }
        else{
            self.wifiConnect = false
        }
    }

    
    
    /**
    每隔3s轮询检测当前心跳,服务器连接状态
    */
    func starttimer(){
        Poller().start(self, method: "startHeartbeat:",timerInter: 3.0)
    }
    func startHeartbeat(timer: NSTimer){
//        var meetingId = 
        
        var url = server.heartBeatServiceUrl + "/" + GBNetwork.getMacId()
        Alamofire.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            if response?.statusCode == 200{
                self.netConnect = true
                self.count = 0
            }
            else{
                self.netConnect = false
                self.count++
                if self.count == 3{
                    self.count = 0
                    timer.invalidate()
                }
            }
        }
    }
    

    
    
    //register current ipad id to server，返回已经注册的id并保存
    func registerCurrentId(){
        let paras = ["id":GBNetwork.getMacId()]
        
        var id: NSString = ""
        Alamofire.request(.POST, reqBoxURL! ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) ->
            
            Void in
            println("post data = \(data!)")
            
            if(error != nil){
                NSLog("注册当前id失败，error ＝ %@", error!.description)
                return
            }
            
            //如果注册成功，则保存当前的iPad的id至../Documents/idData.txt 目录文件中
            if(response?.statusCode == 200){
                id = (data?.objectForKey("id")) as! NSString
                self.idInfoSave(id)
            }
        }
    }
    
    
    //保存当前iPad的id,只在注册成功的情况下才保存id，否则不保存
    func idInfoSave(id: NSString) {
        var idFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        println("该id保存地址 = \(idFilePath)")
        
        var readData = NSData(contentsOfFile: idFilePath)
        var content = NSString(data: readData!, encoding: NSUTF8StringEncoding)!
        
        if(content == id){
            NSLog("当前ipad的id已保存")
            return
        }
        
        var b = id.writeToFile(idFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if b {
            NSLog("当前ipad的id保存成功")
        }
        else{
            NSLog("当前ipad的id保存失败，请重新保存id")
        }
    }
    
    
    //读取本地iddata.txt文本文件记否存在，存在则返回true，否则返回false。
    func IsIdFileExist() -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        
        //判断该文件是否存在，则创建该iddata. txt文件
        var manager = NSFileManager.defaultManager()
        if !manager.fileExistsAtPath(filePath){
            return false
        }
        return true
    }
    
    
    //根据id获取ipad所需信息
    func createBox() -> GBBox{
        
        var result = GBBox()
        var idstr = NSString()
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/idData.txt")
        
        //        if server.getInitialIP() != "192.168.21.90"
        //        {
        //            var manager = NSFileManager.defaultManager()
        //            manager.removeItemAtPath(filePath, error: nil)
        //        }
        
        var b = IsIdFileExist()
        
        //如果iddata文件夹不存在，则创建iddata.txt文件
        if !b{
            var manager = NSFileManager.defaultManager()
            var bCreateFile = manager.createFileAtPath(filePath, contents: nil, attributes: nil)
            if bCreateFile{
                println("idData文件创建成功")
                //idstr = GBNetwork.getMacId()
            }
        }
        
        NSLog("filePath = %@", filePath)
        var readData = NSData(contentsOfFile: filePath)
        idstr = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
        
        //如果不存在，则GBNetwork.getMacId()赋给id
        if (idstr.length <= 0){
            println("请重新注册id")
            self.registerCurrentId()
            idstr = GBNetwork.getMacId()
        }
        
        var urlString = "\(reqBoxURL!)?id=\(idstr)"
        NSLog("urlString = %@", urlString)
        
        getBoxResult { (boxResult) -> () in
            if let jsonResult: AnyObject = boxResult {
                println("result = \(jsonResult)")
                
                //                result.macId = jsonResult.objectForKey("id") as! String
                //                result.type = jsonResult.objectForKey("type") as? GBMeetingType
                //                result.name = jsonResult.objectForKey("name") as! String
            }
        }
        
        return result
    }
    
    
    func getBoxResult(completionHandler: (boxResult: AnyObject?) -> ()){
        var session = NSURLSession.sharedSession()
        var str = server.boxServiceUrl + "?id=" + GBNetwork.getMacId()
        var urlStr = NSURL(string: str)!
        let task = session.dataTaskWithURL(urlStr, completionHandler: { (data, response, err) -> Void in
            if err != nil{
                println("err = \(err.description)")
                return
            }
            var jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)!
            completionHandler(boxResult: jsonResult)
        })
        task.resume()
    }

}





