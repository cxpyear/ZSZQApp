//
//  SearchResultViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/8/21.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import SnapKit

var rowHeight = 65

class SearchResultViewController: UITableViewController {

    var resultPeople = NSMutableArray()
    
    var cellIdentify = "resullCell"
    var searchText: String = "" {
        didSet{
            self.resultPeople.removeAllObjects()
            
            for var i = 0 ; i < totalMembers.count ;i++ {
                var member = GBMember(keyValues: totalMembers[i])
                var name = member.username
                searchText = searchText.lowercaseString
                
                if name.contains(searchText){
                    self.resultPeople.addObject(member)
                }
            }

            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(UINib(nibName: "SignInTableviewCell", bundle: nil), forCellReuseIdentifier: cellIdentify)
        self.tableView.rowHeight = CGFloat(rowHeight)
    
        
        self.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.bottom.equalTo(self.view.snp_bottom)
        }
        
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultPeople.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var gbMember: GBMember = GBMember(keyValues: self.resultPeople[indexPath.row])
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentify, forIndexPath: indexPath) as! SignInTableviewCell
//        cell.lblSignInUserName.text = gbMember.username
        cell.lblSignInUserId.text = gbMember.name
        
        cell.btnSignIn.tag = getCurrentTag(gbMember.username)
        cell.btnSignIn.addTarget(self, action: "signInClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    /**
    根据name获取相应的tag
    
    :param: name 当前的人员名字
    
    :returns: 根据当前人员名字所找到对对应的tag
    */
    func getCurrentTag(name: String) -> Int{
        var tag = 0
        for var i = 0 ; i < totalMembers.count ; i++ {
            var member = GBMember(keyValues: totalMembers[i])
            if member.name == name {
                tag = i
            }
        }
        return tag
    }

    func signInClick(sender: UIButton){
        
        
        
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var readData = NSData(contentsOfFile: filePath)
        if readData?.length > 0{
            var temp = ""
            temp.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        }
        
        var name = totalMembers[sender.tag].name
        var b = name.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        //跳转到AgendaViewController议程界面
        var mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var agendaVC = mainStoryboard.instantiateViewControllerWithIdentifier("SignInAgenda") as! AgendaViewController
        self.presentViewController(agendaVC, animated: true, completion: nil)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
