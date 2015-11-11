//
//  EnterPasswordView.swift
//  ZSApp
//
//  Created by GBTouchG3 on 15/8/25.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class EnterPasswordView: UIView {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblShowError: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.btnOK.layer.cornerRadius = 8
        self.btnCancel.layer.cornerRadius = 8
    }
    
    
    class func getEnterPasswordView(owner: NSObject) -> EnterPasswordView {
        var result = NSBundle.mainBundle().loadNibNamed("EnterPasswordView", owner: owner, options: nil)[0] as! EnterPasswordView
        return result
    }
    
    func returnBtnOK(target: AnyObject, action: Selector) -> UIButton{
        btnOK.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        return btnOK
    }
    
    func returnBtnCancel(target: AnyObject, action: Selector) -> UIButton{
        btnCancel.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        return btnCancel
    }


}
