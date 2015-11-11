//
//  CommonLib.swift
//  ZSApp
//
//  Created by GBTouchG3 on 15/11/9.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

func GreenColor() -> UIColor{
    return UIColor(red: 58/255.0, green: 165/255.0, blue: 53/255.0, alpha: 1.0)
}

var MainStoryboard = UIStoryboard(name: "Main", bundle: nil)

func GBNotificationCenter() -> NSNotificationCenter{
    return NSNotificationCenter.defaultCenter()
}


var ConnectErrorFirstNotification = "ConnectErrorFirstNotification"


//filepath
var memberInfoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/Member.txt")