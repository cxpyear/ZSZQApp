//
//  FileManagerLib.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/8/17.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit


var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")

var CurrentDidChangedNotification = "CurrentDidChangedNotification"
var CurrentDidChangedName = "CurrentDidChangedName"

var FileNeedDownloadNotification = "FileNeedDownloadNotification"

/**
判断获取到的json数据是否和本地存储的json数据一致，是返回true；否则返回false
*/
func isSameJsonFileExist(jsondata: NSData, filePath: String) -> Bool {
    var manager = NSFileManager.defaultManager()
    if manager.fileExistsAtPath(filePath){
        if let contents = manager.contentsAtPath(filePath){
            if jsondata == contents{
                //                println("json is already exist")
                return true
            }
        }
    }
    return false
}

/**
判断获取到id的文件是否存在，是返回true；否则返回false
*/
func isSameFileExist(id: String) -> Bool {
    var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(id).pdf")
    var manager = NSFileManager.defaultManager()
    if manager.fileExistsAtPath(filepath){
        return true
    }else{
        return false
    }
}


func isSamePDFFile(id: String) -> Bool {
    var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(id).pdf")
    var filemanager = NSFileManager.defaultManager()
    
    if filemanager.fileExistsAtPath(filePath){
        return true
    }else{
        return false
    }
}

/**
将data写入制定文件路径下，成功返回true，否则返回false

:param: writeData 要写入的数据
:param: filePath  要写入数据的路径

*/
func dataWriteToFile(writeData: NSData, filePath: String) -> Bool{
    var success = writeData.writeToFile(filePath, options: NSDataWritingOptions.allZeros, error: nil)
    if success == true{
        println("save json data success===success = \(success)")
    }else{
        println("save json data fail fail===fail = \(success)")
    }
    return success
}
