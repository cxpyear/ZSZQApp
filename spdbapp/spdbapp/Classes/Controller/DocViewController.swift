//
//  DocViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class DocViewController: UIViewController,UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate,UITextFieldDelegate, UIScrollViewDelegate, GBBottomViewViewDelegate {
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var btnLeftBottom: UIButton!
    @IBOutlet weak var btnRightBottom: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var txtShowTotalPage: UITextField!
    @IBOutlet weak var txtShowCurrentPape: UITextField!
    @IBOutlet weak var btnPrevious: UIButton!
 
    @IBOutlet weak var btnAfter: UIButton!
    
    var isScreenLocked: Bool = false

    var fileIDInfo = String()
    

    var topBarView = TopbarView()
    var bottomBarView = BottomBarView()

    var totalPage = 0
    var currentPage = 1
    var filePath = String()
    
    var alertCount = 0
    var changeAlert = UIAlertView()
    var offAlertView = UIAlertView()
    
    @IBOutlet weak var docView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileIDInfo).pdf")
        
        loadLocalPDFFile()
        totalPage = initfile()
        GBNotificationCenter().addObserver(self, selector: "getCurrentChange", name: CurrentDidChangedNotification, object: nil)
    }
    
    func initView(){
        //        topView.hidden = true
        //
        //        topBarView = TopbarView.getTopBarView(self)
        ////        topBarView.frame = CGRectMake(0, 0, self.view.frame.width, 20)
        //        self.view.addSubview(topBarView)
        
        bottomBarView = BottomBarView(frame: CGRectMake(0, self.view.height - BottomBarViewH, self.view.width, BottomBarViewH))
        bottomBarView.delegate = self
        self.view.addSubview(bottomBarView)
        
        txtShowCurrentPape.delegate = self
        txtShowTotalPage.text = "共\(totalPage)页"
        self.currentPage = 1
        
        self.docView.scrollView.delegate = self
        
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "hideOrShowBottomBar:")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initView()
        
        
    }
    
    func getCurrentChange(){
        if alertCount == 0 {
            changeAlert = UIAlertView(title: "提 示", message: "当前会议信息发生改变，请回到主页面重试", delegate: self, cancelButtonTitle: "确 定")
            changeAlert.show()
            alertCount = 1
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView == self.changeAlert{
            var mainVc = MainStoryboard.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
            self.presentViewController(mainVc, animated: true, completion: nil)
        }else if alertView == offAlertView{
            if buttonIndex == 0{
                bNeedLogin = true
                bottomBarView.lblUser.text = ""
                var mainVc = MainStoryboard.instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
                self.presentViewController(mainVc, animated: true, completion: nil)
                
            }
        }
    }
    
    func offLoginBtnClick(){
        offAlertView = UIAlertView(title: "提 示", message: "确认退出系统?", delegate: self , cancelButtonTitle: "确 定", otherButtonTitles: "取 消")
        offAlertView.show()
    }


    
    func bottomBarView(bottomView: BottomBarView, didClickBtn: GBBottmBarViewType) {
        println("btn agenda = \(didClickBtn)")
        switch didClickBtn.rawValue {
        case 0:
            println("btn0")
            self.dismissViewControllerAnimated(true, completion: nil)
            break
            
        case 1:
            println("btn1")
            break
            
        case 2:
            offLoginBtnClick()
            break
            
        default:
            println("btnd")
            break
        }
        
    }

    
//    func hideTopBar(gesture: UITapGestureRecognizer){
//        topView.hidden = (topView.hidden == true) ? false : true
//    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.txtShowCurrentPape{
            self.txtShowCurrentPape.endEditing(true)
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        if textField == self.txtShowCurrentPape{
            if textField.text.isEmpty{
                return
            }
            
            var value = self.txtShowCurrentPape.text
            var temp = String(value)
            var page = temp.toInt()!
            if page <= 0{
                return
            }
            skipToPage(page)
            currentPage = page
           
        }
    }
    
    /**
    跳转到pdf指定的页码
    
    :param: num 指定的pdf跳转页码位置
    */
    func skipToPage(num: Int){
        var totalPDFheight = docView.scrollView.contentSize.height
        var pageHeight = CGFloat(totalPDFheight / CGFloat(totalPage))
        
        var specificPageNo = num
        if specificPageNo <= totalPage{
            
            var value2 = CGFloat(pageHeight * CGFloat(specificPageNo - 1))
            var offsetPage = CGPointMake(0, value2)
            docView.scrollView.setContentOffset(offsetPage, animated: true)
        }
    }

    
    /**
    跳转到pdf文档第一页
    */
    @IBAction func btnToFirstPageClick(sender: UIButton) {
        skipToPage(1)
        currentPage = 1
        self.txtShowCurrentPape.text = String(currentPage)
    }
    
    /**
    跳转到pdf文档最后一页
    */
    @IBAction func btnToLastPageClick(sender: UIButton) {
        skipToPage(totalPage)
        currentPage = totalPage
        self.txtShowCurrentPape.text = String(currentPage)
    }
    
    /**
    跳转到pdf文档下一页
    */
    @IBAction func btnToNextPageClick(sender: UIButton) {
        if currentPage < totalPage  {
            ++currentPage
            skipToPage(currentPage)
            self.txtShowCurrentPape.text = String(currentPage)
            
        }
    }

    
    /**
    跳转到pdf文档上一页
    */
    @IBAction func btnToPreviousPageClick(sender: UIButton) {
        if currentPage > 1 {
            --currentPage
            skipToPage(currentPage)
            
            self.txtShowCurrentPape.text = String(currentPage)
        }
        println("==============1")
    }
    
    
    
    
    func hideOrShowBottomBar(gesture: UITapGestureRecognizer){
        self.bottomBarView.hidden = !self.bottomBarView.hidden
        topView.hidden = !topView.hidden
    }
    
    func autoHideBottomBarView(timer: NSTimer){
        if self.bottomBarView.hidden == false{
            self.bottomBarView.hidden = true
        }
    }
    
    
    
    
    /**
    返回当前pdf文件的总页数
    
    :returns: 当前pdf文档总页数
    */
    func initfile() -> Int {
        var path: CFString = CFStringCreateWithCString(nil, filePath, CFStringEncoding(CFStringBuiltInEncodings.UTF8.rawValue))
        var url: CFURLRef = CFURLCreateWithFileSystemPath(nil , path, CFURLPathStyle.CFURLPOSIXPathStyle, 0)
        var document: CGPDFDocumentRef = CGPDFDocumentCreateWithURL(url)
        var totalPages = CGPDFDocumentGetNumberOfPages(document)
        return totalPages
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        var pdfHeight = scrollView.contentSize.height
        var onePageHeight = pdfHeight / CGFloat(totalPage)
        
        var page = (scrollView.contentOffset.y) / onePageHeight
        var p = Int(page + 0.5)
        self.txtShowCurrentPape.text = "\(p + 1)"
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //加锁
    @IBAction func addLock(sender: UIButton) {
        self.isScreenLocked = !self.isScreenLocked
        if self.isScreenLocked == true{
            sender.setBackgroundImage(UIImage(named: "Lock-50"), forState: UIControlState.Normal)
        }else{
            sender.setBackgroundImage(UIImage(named: "Unlock-50"), forState: UIControlState.Normal)
        }
        topBarView.lblIsLocked.text = (self.isScreenLocked == true) ? "当前屏幕已锁定" : ""
    }
    
    override func shouldAutorotate() -> Bool {
        return !self.isScreenLocked
    }
    
    
    /**
    加载当前pdf文档
    */
    func loadLocalPDFFile(){
//        var filePath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileIDInfo).pdf")
        var urlString = NSURL(fileURLWithPath: "\(filePath)")
        var request = NSURLRequest(URL: urlString!)
        self.docView.loadRequest(request)
        println("path = \(filePath)")
        skipToPage(1)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
