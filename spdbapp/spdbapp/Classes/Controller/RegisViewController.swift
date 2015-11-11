//
//  RegisViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/26.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit


class RegisViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var viewparent: UIView!
    @IBOutlet weak var mainSignInUserTv: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var cover: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var lblShowError: UILabel!

    var cellIdentify = "maincell"
    
    var password = Int()
    var userName = String()
    
    
    @IBOutlet weak var btnEnterPassword: UIButton!
    @IBOutlet weak var btnCancelEnterPassword: UIButton!
    
    
//    var enterPassword = EnterPasswordView()
    var kbHeight: CGFloat!
    
    
    var allMembers = NSMutableArray()
    
    var currentChangeAlert = UIAlertView()
    
    
    
    var searchText: String = "" {
        didSet{
            self.allMembers.removeAllObjects()
//            println("text = \(self.searchText)")
            for var i = 0 ; i < totalMembers.count ;i++ {
                var member = GBMember(keyValues: totalMembers[i])
                var name = member.name.lowercaseString
                searchText = searchText.lowercaseString
                
                if name.contains(searchText){
                   self.allMembers.addObject(member)
                }
            }
            
            self.mainSignInUserTv.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        totalMembers = current.member
        
        self.btnEnterPassword.layer.cornerRadius = 8
        self.btnCancelEnterPassword.layer.cornerRadius = 8
        

        initSubViewFrame()
        
        
        self.btnEnterPassword.addTarget(self, action: "checkPassword", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnCancelEnterPassword.addTarget(self, action: "cancelEnterPassword", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func initSubViewFrame(){
//        topBarView = TopbarView.getTopBarView(self)
//        self.view.addSubview(topBarView)
        
        mainSignInUserTv.rowHeight = 65
        mainSignInUserTv.tableFooterView = UIView(frame: CGRectZero)
        
        mainSignInUserTv.registerNib(UINib(nibName: "SignInTableviewCell", bundle: nil), forCellReuseIdentifier: cellIdentify)
        
        
        self.cover.hidden = true
        self.cover.addTarget(self, action: "coverClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.loginView.hidden = true
        self.loginView.layer.cornerRadius = 10
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    

    
    
    override func shouldAutorotate() -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func cancelEnterPassword(){
        self.loginView.hidden = true
        self.txtPassword.text = ""
        self.view.endEditing(true)
    }
    
    func checkPassword(){
        println("password = \(self.password)")
        
        if self.txtPassword.text.isEmpty {
            return
        }
        
        var dict = NSDictionary(contentsOfFile: memberInfoPath)
        if let pwdValue = (dict?.valueForKey("password"))?.integerValue{
            if let txtPwdValue = self.txtPassword.text.toInt(){
                if pwdValue == txtPwdValue{
                    bNeedLogin = false
                    
                    var agendaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignInAgenda") as! AgendaViewController
                    self.presentViewController(agendaVC, animated: true, completion: nil)
                    self.lblShowError.text = ""
                }else{
                    bNeedLogin = true
                    self.txtPassword.text = ""
                    self.lblShowError.text = "密码错误,请重试..."
                }
            }
        }else{
            bNeedLogin = true
            self.txtPassword.text = ""
            self.lblShowError.text = "密码错误,请重试..."
        }
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        
//        self.checkPassword()
//        
//    }
    
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if textField == self.txtPassword{
//            self.txtPassword.resignFirstResponder()
//        }
//        
//        return true
//    }
  
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var rowCount = self.searchbar.text.length > 0 ? self.allMembers.count : totalMembers.count
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var anyData: AnyObject = (self.searchbar.text.length > 0) ? allMembers[indexPath.row] : totalMembers[indexPath.row]
        var gbMember = GBMember(keyValues: anyData)
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentify, forIndexPath: indexPath) as! SignInTableviewCell
        
        cell.lblSignInUserId.text = gbMember.name
        cell.btnSignIn.tag = indexPath.row
        cell.btnSignIn.addTarget(self, action: "signInClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func saveMemberToDic(mb: GBMember) -> Bool {
        var dict = NSMutableDictionary()
        
        dict["id"] = mb.id
        dict["name"] = mb.name
        dict["type"] = mb.type
        dict["role"] = mb.role
        dict["password"] = mb.password
        dict["username"] = mb.username
        
        self.password = mb.password
        
        member = mb
        
        var success = dict.writeToFile(memberInfoPath, atomically: true)
        return success
    }


    func signInClick(sender: UIButton){
        self.loginView.hidden = false
        var mb: GBMember = self.searchbar.text.length > 0 ? GBMember(keyValues: allMembers[sender.tag]) : GBMember(keyValues: totalMembers[sender.tag])
        password = mb.password
        userName = mb.username
        var success = saveMemberToDic(mb)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.text = ""
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.cover.hidden = false
            self.cover.alpha = 0.8
        })
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.text = ""
        
        self.cover.hidden = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if count(searchText) > 0 {
            self.cover.hidden = true
            self.searchText = searchText
        }else{
            self.cover.hidden = false
            self.searchText = ""
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchbar.resignFirstResponder()
        self.cover.hidden = true
    }
    
    func coverClick(){
        searchbar.text = ""
        self.cover.hidden = true
        self.searchbar.resignFirstResponder()
    }

    
    func keyboardWillHide(sender: NSNotification) {
        self.animateTextField(false)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = (keyboardSize.width > keyboardSize.height) ? (keyboardSize.height * 0.5) : 0
                self.animateTextField(true)
            }
        }
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        //        println("movement = \(movement)")
        UIView.animateWithDuration(0.3, animations: {
            self.loginView.frame = CGRectOffset(self.loginView.frame, 0, movement)
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
