//
//  BottomBarView.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/7/27.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

protocol GBBottomViewViewDelegate: NSObjectProtocol{
    func bottomBarView(bottomView: BottomBarView, didClickBtn:GBBottmBarViewType)
}


enum GBBottmBarViewType: Int{
    case GBBottmBarViewTypeBack = 0
    case GBBottmBarViewTypeReconnect = 1
    case GBBottmBarViewTypeUser = 2
}

class BottomBarView: UIView {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    var delegate: GBBottomViewViewDelegate?
    
    var backBtn = UIButton()
    var reconnectBtn = UIButton()
    var userBtn = UIButton()
    var lblUser = UILabel()

    
   
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.hidden = true

        Poller().start(self, method: "checkstatus:", timerInter: 5.0)
        
        backBtn = setUpBtn("Return-50", tag: GBBottmBarViewType.GBBottmBarViewTypeBack)
        reconnectBtn = setUpBtn("Reconnect", tag: GBBottmBarViewType.GBBottmBarViewTypeReconnect)
        userBtn = setUpBtn("User-50", tag: GBBottmBarViewType.GBBottmBarViewTypeUser)
        
        
        
        if appManager.netConnect == true {
            self.reconnectBtn.hidden = true
        }
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpBtn(imgName: String, tag: GBBottmBarViewType) -> UIButton{
        var btn = UIButton()
        btn.setImage(UIImage(named: imgName), forState: UIControlState.Normal)
        btn.tag = tag.rawValue
        
        if btn.tag == 0 || btn.tag == 2{
            btn.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }else if btn == 1{
            btn.addTarget(self, action: "btnReConnectClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        self.addSubview(btn)
        return btn
    }
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var count = self.subviews.count
        var baseW = self.superview!.width / CGFloat(count)
        for var i = 0 ; i < count ; i++ {
            var btn = self.subviews[i] as! UIButton
            var btnX = baseW * CGFloat(i)
            var btnWH: CGFloat = (i != count - 1) ? 45 : 32
    
            btn.frame = CGRectMake(btnX , 2, btnWH, btnWH)
            btn.center.x = baseW * (0.5 + CGFloat(i))
            
            if i == (count - 1){
                self.lblUser.frame = CGRectMake(0, btnWH + 2, 120, 15)
                self.lblUser.font = UIFont(name: "Heiti SC", size: 12.0)
                self.lblUser.center.x = btn.width * 0.5
                self.lblUser.textAlignment = NSTextAlignment.Center
                self.lblUser.text = member.username
                btn.addSubview(self.lblUser)
            }
        }
    }

    
    func btnClick(sender: UIButton){
        if self.delegate?.respondsToSelector("bottomBarView(,didClickBtn:)") != nil{
            self.delegate?.bottomBarView(self, didClickBtn: GBBottmBarViewType(rawValue: sender.tag)!)
        }
    }
    
    //页面下方的“重连”按钮出发的事件
    func btnReConnectClick(sender: UIButton){
        appManager.starttimer()
    }

    
    func checkstatus(timer: NSTimer){
        reconnectBtn.hidden = (appManager.netConnect == true) ? true : false
    }
    
    
    
//    func getName() {
//
//        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
//        var readData = NSData(contentsOfFile: filePath)
//        var name = NSString(data: readData!, encoding: NSUTF8StringEncoding)! as NSString
//        
//        if (name.length > 0){
//            self.lblUserName.text = name as String
//        }
//    }
    
//   class func getBottomInstance(owner: UIViewController) -> BottomBarView {
//    
//        var result = NSBundle.mainBundle().loadNibNamed("BottomBarView", owner: owner, options: nil)[0] as! BottomBarView
//
//        if owner.view != nil{
//            result.frame = CGRectMake(0, owner.view.frame.height - 49, owner.view.frame.width , 49)
//        }
//    
//        result.btnBack.addTarget(self, action: "btnBack:", forControlEvents: UIControlEvents.TouchUpInside)
//       
//        return result
//    }
    
    
//    class func btnBack(sender: UIButton){
//        println("button = \(sender.superview?.superview)")
//    }
//    
//    func returnBtnBack(target: AnyObject, action: Selector) -> UIButton{
//        btnBack.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
//        return btnBack
//    }
//    
//    
//    func returnBtnUser(target: AnyObject, action: Selector) -> UIButton{
//        btnUser.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
//        return btnUser
//    }
    
    
    
}
