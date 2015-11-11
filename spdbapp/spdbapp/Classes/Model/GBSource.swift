//
//  GBSource.swift
//  SPDB(Mini)
//
//  Created by GBTouchG3 on 15/10/23.
//  Copyright (c) 2015年 GBTouchG3. All rights reserved.
//

import UIKit

class GBSource: NSObject {
    /** 当前会议名 */
//    var name: String = ""
//    
//    /** 当前会议开始时间 */
//    var startTime: NSDate = NSDate()
//    
//    /** 当前会议状态 */
//    var status: Bool?
//    
//    /** 当前文件id */
//    var id: String = ""
//    
//    /** 当前会议所有议程 */
//    var agendas = NSArray()
//    //[GBAgenda]()
//    
//    /** 当前会议所有 */
//    var sources = NSArray()
//    //NSArray()
//    //[GBSource]()
//    
//    /** 当前参会人员 */
//    var member = [String]()
//    
//    var meetingtype = String()
//    var memberrole = String()
    
        var id: String = ""
        var type: String = ""
        var name: String = ""
        var sourextension: String = ""
        var sourpublic: String = ""
        var link: String = ""
        var aidlink: String = ""
        var meetingtype = String()
//        var memberrole = String()
    
    
    override static func replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
//        var dict = ["sources" : "source", "agendas" : "agenda"]
        
        var dict = ["sourextension" : "extension", "aidlink" : "aid-link", "sourpublic" : "public"  ]
        return dict
    }
//
//    
//    override static func objectClassInArray() -> [NSObject : AnyObject]! {
////        var dict = ["agendas" : "GBAgenda", "sources" : "GBSource"]
//        
//        var dict = ["sources" : "GBSource"]
//        return dict
//    }

}
