//
//  SourceFileViewcontroller.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/7/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class SourceFileViewcontroller: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, GBBottomViewViewDelegate {

    @IBOutlet weak var sourceTableview: UITableView!
    @IBOutlet weak var lblShowMeetingName: UILabel!
    @IBOutlet weak var lblShowAgendaName: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var agendaNameInfo = String()
    var agendaIdInfo = Int()
    var sourceCount = Int()
    
    var gbSourceInfo = NSMutableArray()
    
    var bottomBarView = BottomBarView()
    
    var offAlertView = UIAlertView()
    var changeAlert = UIAlertView()
    var alertCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var agenda = GBAgenda(keyValues: current.agendas[agendaIdInfo])
        getSourceWithAgendaId(agenda, sourceCount: sourceCount)
        
        self.lblShowAgendaName.text = self.agendaNameInfo
        self.lblShowMeetingName.text = current.name
        loadInitSubViews()
        Poller().start(self, method: "autoHideBottomBarView:", timerInter: 5.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCurrentChange", name: CurrentDidChangedNotification, object: nil)

        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getCurrentChange(){
        if alertCount == 0 {
            changeAlert = UIAlertView(title: "提 示", message: "当前会议信息发生改变，请回到主页面重试", delegate: self, cancelButtonTitle: "确 定")
            changeAlert.show()
            alertCount = 1
        }
    }

    
    func getSourceWithAgendaId(agenda: GBAgenda ,sourceCount: Int){
        if sourceCount <= 0 {
            return
        }
        
        for var k = 0 ; k < sourceCount; k++ {
            var sourceId: AnyObject = agenda.source[k]
            for var i = 0 ; i < current.sources.count ; i++ {
                var cSource = GBSource(keyValues: current.sources[i])
                if cSource.id == sourceId as! String{
                    self.gbSourceInfo.addObject(cSource)
                }
            }
        }
    }
    
    
    func loadInitSubViews(){
        self.view.addSubview(TopbarView.getTopBarView(self))
        
        bottomBarView = BottomBarView(frame: CGRectMake(0, self.view.height - BottomBarViewH, self.view.width, BottomBarViewH))
        bottomBarView.delegate = self
        self.view.addSubview(bottomBarView)
        
        sourceTableview.registerNib(UINib(nibName: "SourceTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        sourceTableview.tableFooterView = UIView(frame: CGRectZero)
        
        Poller().start(self, method: "reload", timerInter: 2)
        
        self.tapGesture.addTarget(self, action: "hideOrShowBottomBar:")
        self.view.addGestureRecognizer(tapGesture)
    }

    
    //页面旋转时候，自动调整底部按钮的布局
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.bottomBarView.hidden = true
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.bottomBarView.hidden = false
        self.bottomBarView.frame = CGRectMake(0, self.view.height - BottomBarViewH, self.view.width, BottomBarViewH)
    }
   
    
    func hideOrShowBottomBar(gesture: UITapGestureRecognizer){
        self.bottomBarView.hidden = !self.bottomBarView.hidden
    }
    
    func autoHideBottomBarView(timer: NSTimer){
        if self.bottomBarView.hidden == false{
            self.bottomBarView.hidden = true
        }
    }
    
    

    func reload(){
        self.sourceTableview.reloadData()
    }
    

    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
    隐藏顶部菜单栏
    
    :returns: true表示隐藏顶部菜单栏
    */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func bottomBarView(bottomView: BottomBarView, didClickBtn: GBBottmBarViewType) {
        switch didClickBtn.rawValue {
        case 0:
            self.dismissViewControllerAnimated(true, completion: nil)
            break
            
        case 1:
            println("btn1")
            break
            
        case 2:
            println("btn2")
            offLoginBtnClick()
            break
            
        default:
            println("btnd")
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
                var mainVc = MainStoryboard.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
                self.presentViewController(mainVc, animated: true, completion: nil)

            }
        }else if alertView == self.changeAlert {
            var mainVc = MainStoryboard.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
            self.presentViewController(mainVc, animated: true, completion: nil)
        }
    }


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gbSourceInfo.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SourceTableViewCell
        var sourceRow = GBSource(keyValues:self.gbSourceInfo[indexPath.row])
        
        cell.lblShowSourceFileName.text = sourceRow.name.stringByDeletingPathExtension
        
        
        if isSamePDFFile(sourceRow.id){
            cell.downloadProgressBar.hidden = true;
            cell.lblShowDownloadPercent.hidden = true
            cell.imgShowFileStatue.image = UIImage(named: "Arrow-50")
        }else{
        
            for var i = 0; i < downloadlist.count  ; i++ {
                if sourceRow.id  == downloadlist[i].fileid.stringByDeletingPathExtension {
                    if (isSamePDFFile("\(sourceRow.id).pdf")){
                        cell.downloadProgressBar.hidden = true;
                        cell.lblShowDownloadPercent.hidden = true
                        cell.imgShowFileStatue.image = UIImage(named: "File-50")
                    }else{
                        cell.lblShowDownloadPercent.text = "\(Int(Float(downloadlist[i].filebar) * 100))%"
                        cell.downloadProgressBar.progress = Float(downloadlist[i].filebar)
                        cell.imgShowFileStatue.image = UIImage(named: "Arrow-50")
                    }
                }
            }
        }
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        var source = GBSource(keyValues: self.gbSourceInfo[indexPath.row])
        
        var isFileExist = isSamePDFFile(source.id)
        if isFileExist == false {
            UIAlertView(title: "提醒", message: "文件还在下载，请稍候打开", delegate: self, cancelButtonTitle: "确定").show()
        }else{
            var docView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DocVC") as! DocViewController
            docView.fileIDInfo = source.id
            self.presentViewController(docView, animated: true, completion: nil)
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}