//
//  GBAgenda.swift
//  ZSApp
//
//  Created by GBTouchG3 on 15/11/6.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit

class GBAgenda: NSObject {
   
    /** 议程id*/
    var id = String()
    
    /** 议程 名称*/
    var name = String()
    
    /** 议程下的文件*/
    var source = NSArray()
    
    /** 议程 索引*/
    var index = Int()
    
    /** 议程 开始时间*/
    var startTime = String()
    
    /** 议程 截止时间*/
    var endTime = String()
    
    /** 汇报人*/
    var reporter = String()
    
    override static func replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
//        var dict = ["sources" : "source", "agendas" : "agenda"]
        
        var dict = ["startTime" : "starttime", "endTime" : "endtime"]
        return dict
    }
    
    
    override static func objectClassInArray() -> [NSObject : AnyObject]! {
//        var dict = ["agendas" : "GBAgenda", "sources" : "GBSource"]
        
        var dict = ["source" : "GBSource"]
        return dict
    }
    
}
