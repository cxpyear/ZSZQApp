//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

var BottomBarViewH = CGFloat(50)



class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GBBottomViewViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var tvAgenda: UITableView!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    var bottomBarView = BottomBarView()
    var cellIdentify = "agendaCell"
    
    
    var gbAgendInfo = NSArray()
    
    var alertCount = 0
    var offAlertView = UIAlertView()
    var changeAlert = UIAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLoadSubViews()
        
        gbAgendInfo = current.agendas
        self.lblMeetingName.text = current.name
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCurrentChange", name: CurrentDidChangedNotification, object: nil)
        
    }
    
    
    func getCurrentChange(){
        if alertCount == 0 {
            changeAlert = UIAlertView(title: "提 示", message: "当前会议信息发生改变，请回到主页面重试", delegate: self, cancelButtonTitle: "确 定")
            changeAlert.show()
            alertCount = 1
        }
    }
    
    func initLoadSubViews(){

        //tvAgenda init
        self.tvAgenda.registerNib(UINib(nibName: "AgendaTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentify)
        self.tvAgenda.rowHeight = 70
        self.tvAgenda.tableFooterView = UIView(frame: CGRectZero)
        
        //topbarview init
        self.view.addSubview(TopbarView.getTopBarView(self))
        
        //bottombarview init
        bottomBarView.frame = CGRectMake(0, self.view.height - BottomBarViewH, self.view.width, BottomBarViewH)
        bottomBarView.delegate = self
        self.view.addSubview(bottomBarView)
        
        //auto hide gesture
        tapGesture.addTarget(self, action: "hideOrShowBottomBar:")
        self.view.addGestureRecognizer(tapGesture)
        
        Poller().start(self, method: "autoHideBottomBarView:", timerInter: 5.0)
    }
    
    func hideOrShowBottomBar(gesture: UITapGestureRecognizer){
        self.bottomBarView.hidden = !self.bottomBarView.hidden
    }
    
    func autoHideBottomBarView(timer: NSTimer){
        self.bottomBarView.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

    
    func loginOut(){
        var loginFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/LoginInfo.plist")
        var manager = NSFileManager.defaultManager()
        var fileDic = NSMutableDictionary(contentsOfFile: loginFilePath)
        if fileDic?.count == 2{
            fileDic?.removeObjectForKey("isLogin")
            fileDic?.setObject(false , forKey: "isLogin")
            fileDic?.writeToFile(loginFilePath, atomically: true)
        }
        
        var agendaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignInAgenda") as! AgendaViewController
        self.presentViewController(agendaVC, animated: true, completion: nil)

    }
    

    //页面旋转时候，自动调整底部按钮的布局
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.bottomBarView.hidden = true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.bottomBarView.hidden = false
        self.bottomBarView.frame = CGRectMake(0, self.view.height - BottomBarViewH, self.view.width, BottomBarViewH)
    }
    
    
    
    
    func bottomBarView(bottomView: BottomBarView, didClickBtn: GBBottmBarViewType) {
        switch didClickBtn.rawValue {
        case 0:
            var mainVc = MainStoryboard.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
            self.presentViewController(mainVc, animated: true, completion: nil)
            break
            
        case 1:
            break
            
        case 2:
            offLoginBtnClick()
            break
            
        default:
            break
        }

    }
    
    func offLoginBtnClick(){
        offAlertView = UIAlertView(title: "提 示", message: "确认退出系统?", delegate: self , cancelButtonTitle: "确 定", otherButtonTitles: "取 消")
        offAlertView.show()
    }
  
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView == offAlertView{
            if buttonIndex == 0{
                bNeedLogin = true
                bottomBarView.lblUser.text = ""
            }
        }else if alertView == changeAlert{
            
        }
        
        var mainVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
        self.presentViewController(mainVc, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gbAgendInfo.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var agenda = GBAgenda(keyValues: self.gbAgendInfo[indexPath.row])
        
        var sourceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sourceVC") as! SourceFileViewcontroller
        sourceVC.agendaNameInfo = agenda.name
        sourceVC.agendaIdInfo = indexPath.row
        sourceVC.sourceCount = agenda.source.count
        self.presentViewController(sourceVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AgendaTableViewCell = (tableView.dequeueReusableCellWithIdentifier(cellIdentify, forIndexPath: indexPath) as! AgendaTableViewCell)
        
        if let agendaRow = GBAgenda(keyValues: self.gbAgendInfo[indexPath.row]){
            
            var startArray: [String] = agendaRow.startTime.componentsSeparatedByString(" ")
            var endArray: [String] = agendaRow.endTime.componentsSeparatedByString(" ")
            
            cell.lblDate.text = startArray[0]
            
            if startArray.count == 2 && endArray.count == 2{
                cell.lblTime.text = "\(startArray[1]) - \(endArray[1])"
            }
            cell.lblReporter.text = agendaRow.reporter
            cell.lbAgenda.text = agendaRow.name
        }
        
        return cell
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        GBNotificationCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
