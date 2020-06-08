//
//  TodayViewController.swift
//  PetWidget
//
//  Created by student46 on 2020/6/4.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bdLabelWidget: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        let userDefaults = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
        if let bdlabel = userDefaults?.string(forKey: "bdlabel"){
            self.bdLabelWidget.text = bdlabel
            let myUserDefault = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
            
            if let viewimage = myUserDefault?.data(forKey: "image"){
                imageView.image = UIImage(data: viewimage)
            }else{
                print("Fail")
                imageView.image = UIImage(named: "setup.png")
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //            if let image = UserDefaults.init(suiteName: "group.org.iiiedu.lab.NoteApp10.Widget")?.value(forKey: "image"){
        //                self.imageView.image = image as? UIImage
    }
}


func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
    completionHandler(NCUpdateResult.newData)
}
/*func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
 if activeDisplayMode == .expanded{
 self.preferredContentSize = CGSize(width: 320.0, height: 320.0)
 }else{
 self.preferredContentSize = CGSize.zero //不設定顯示會怪奇怪
 }
 }
 }*/


/*
 class TodayViewController: UIViewController, NCWidgetProviding {
 
 typealias updateResult = (NCUpdateResult) -> Void
 @IBOutlet weak var tempImageView: UIImageView!
 override func viewDidLoad() {
 super.viewDidLoad()
 self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
 }
 func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
 if activeDisplayMode == .expanded{
 self.preferredContentSize = CGSize(width: 320.0, height: 320.0)
 }else{
 self.preferredContentSize = CGSize.zero //不設定顯示會怪奇怪
 }
 }
 //系統會自動判定,呼叫這個func,自動刷新 ,1.widget啟動時2.user可能會用widget時
 //escaping標注的意思是這個func結束後參數還可以活著不會消失,因為func或整個程式結束後還可能會用到,都用在閉包
 //系統給completionHandler,一定要處理它
 func widgetPerformUpdate(completionHandler: (@escaping updateResult)) {
 // Perform any setup necessary in order to update the view.
 
 // If an error is encountered, use NCUpdateResult.Failed
 // If there's no update required, use NCUpdateResult.NoData
 // If there's an update, use NCUpdateResult.NewData
 //時機適當時 叫app刷新
 //1)
 doRefresh(completionHandler: completionHandler)
 //6)   //回報東西給系統,事情做完之後用這個completionHandler
 //     completionHandler(NCUpdateResult.newData)
 }
 @IBAction func refreshBtnPressed(_ sender: Any) {
 doRefresh(completionHandler: nil )
 }
 
 //點圖片呼叫
 @IBAction func imageViewTapped(_ sender: Any) {
 // ://123當成參數傳過來
 
 
 guard let url = URL(string:"banana://123")else{
 assertionFailure("Invalid URL")
 return
 }
 //context環境 提供一個環境,叫醒主程式裡的func open url , completionHandler拿到那個func回傳的true或是false
 self.extensionContext?.open(url, completionHandler: { (success) in
 
 })
 }
 
 //可選型別不用加@escaping,系統已經特殊處理,一般型別的closure再加(會繼續使用的)
 func doRefresh(completionHandler: updateResult?) {
 let urlString = "https://www.cwb.gov.tw/Data/temperature/temp.jpg"
 //2)
 guard let url = URL(string: urlString) else {
 assertionFailure("Fail to convert string to URL.")
 completionHandler?(.failed)
 return
 }
 let config = URLSessionConfiguration.default
 let session = URLSession(configuration: config)
 //3) 下面包clousure(物件化的程式碼)還沒呼叫就不會執行,包成一包當成參數丟進去dataTask
 let task = session.dataTask(with: url) { (data, response, error) in
 //7)
 if let error = error {
 print("Download Fail: \(error)")
 completionHandler?(.failed)
 //8a)
 return
 }
 guard let data = data else {
 print("Incalid data ")
 completionHandler?(.failed)
 //8b)
 return
 }
 
 DispatchQueue.main.async {
 self.tempImageView.image = UIImage(data: data)
 }
 completionHandler?(.newData)//可選行別的閉包用?
 //8c)
 }
 //4)
 task.resume() //會開啟background thread 執行7~8用網路下載資料,比ＣＰＵ慢很多Main thread(1~3~4,5~6)
 session.finishTasksAndInvalidate() //請釋放 自殺`
 //5)
 }
 
 }*/
