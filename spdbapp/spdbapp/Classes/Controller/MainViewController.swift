//
//  MainViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/8/21.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

var initCount = 0

class MainViewController: UIViewController {

    var builder = Builder()
    
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblShowMeetingName: UILabel!
    
    var topBarView = TopbarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        if initCount == 0{
            getCurrentFirst()
            GBNotificationCenter().addObserver(self, selector: "getCurrentPostError", name: ConnectErrorFirstNotification, object: nil)
            initCount = 1
        }else{
            initView()
        }
        
        GBNotificationCenter().addObserver(self, selector: "getCurrent:", name: CurrentDidChangedNotification, object: nil)
        
    }
    
    func getCurrentPostError(){
        UIAlertView(title: "提 示", message: "网络连接失败，请检查网络设置后重试", delegate: self , cancelButtonTitle: "确定").show()
    }
    
    func getCurrent(notification: NSNotification){
//        if let userinfo = notification.userInfo{
//            if let currentInfo: AnyObject = userinfo[CurrentDidChangedName]{
//                current = GBCurrent(keyValues: currentInfo)
                initView()
//            }
//        }
    }

    
    func getCurrentFirst(){
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.AllowFragments) { (request , response , data , error ) -> Void in
            if error != nil || data == nil {
                println("get first data = \(error)")
                NSNotificationCenter.defaultCenter().postNotificationName(ConnectErrorFirstNotification, object: nil)
                return
            }else{
                if let dataResult: AnyObject = data{
//                    println("datar = \(JSON(dataResult))")
                    if let result = GBCurrent(keyValues: dataResult){
                        current = result
                        if current.id.isEmpty == false{
                            DownLoadManager()
                        }else{
                            UIAlertView(title: "提 示", message: "当前暂无会议", delegate: self , cancelButtonTitle: "确定").show()
                        }
                        self.initView()
                    }
                }
            }
        }
    }

    
    func initView(){
        if current.id.isEmpty{
            btnSignIn.enabled = false
            btnSignIn.backgroundColor = UIColor.grayColor()
            lblShowMeetingName.text = "暂 无 会 议"
        }else{
            lblShowMeetingName.text = current.name
            btnSignIn.enabled = true
            btnSignIn.backgroundColor = GreenColor()
            lblShowMeetingName.text = current.name
        }
        
        btnSignIn.layer.cornerRadius = 10
    }
    
    @IBAction func btnStart(sender: UIButton) {
        println("bNeedLogin = \(bNeedLogin)")
        
        if bNeedLogin == true{
            var loginVC = MainStoryboard.instantiateViewControllerWithIdentifier("view") as! RegisViewController
            self.presentViewController(loginVC, animated: true, completion: nil)
        }else{
            var agendaVC = MainStoryboard.instantiateViewControllerWithIdentifier("SignInAgenda") as! AgendaViewController
            self.presentViewController(agendaVC, animated: true, completion: nil)
        }
    }
    
    //隐藏顶部菜单条
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //监听设置界面参数改变
//    func defaultsSettingsChanged() {
//        let standardDefaults = NSUserDefaults.standardUserDefaults()
//        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
//        var settingsDict: NSMutableDictionary = NSMutableDictionary()
//        
//        // 监听txtFileURL是否发生改变  默认情况下是192.168.16.142
//        var value = standardDefaults.stringForKey("txtBoxURL")
//        if value == nil{
//            value = "192.168.21.48"
//        }
//        settingsDict.setObject(value!, forKey: "txtBoxURL")
//        
//        var b = settingsDict.writeToFile(filepath, atomically: true)
//        println("url new value ============ \(value)")
//        
////        var isClearHistoryInfo = standardDefaults.boolForKey("clear_historyInfo")
////        if isClearHistoryInfo == true{
////            server.clearHistoryInfo("pdf")
////        }
////        
////        var isClearConfigInfo = standardDefaults.boolForKey("clear_configInfo")
////        if isClearConfigInfo == true{
////            server.clearHistoryInfo("txt")
////        }
//    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
