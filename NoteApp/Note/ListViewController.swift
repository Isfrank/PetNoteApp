//
//  ListViewController.swift
//  NoteApp
//
//  Created by Frank on 2020/4/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import CoreData
import StoreKit
import MessageUI
import FirebaseAnalytics
import GoogleMobileAds

class ListViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,NoteViewControllerDelegate, MFMailComposeViewControllerDelegate, GADBannerViewDelegate
    
{
    var bannerView: GADBannerView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var data: [Note] = []//model:資料用Array來裝，裏面只能放Note類型的物件
    var dataStringArray = [String]()
    var searchResult: [String]  = []
    var searchController: UISearchController!
    var isSearching = false
    //storyboard會呼叫
    //xib
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //self.loadFromFile()//查 Archiving
        self.loadFromCoreData()
        
        //新 刪 修 查
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.noteUpdate(notification:)), name: .noteUpdated, object: nil)
    }
    
    @objc func noteUpdate(notification : Notification) {
        
        if let note = notification.userInfo?["note"] as? Note {
            //Optional<Note>
            // self.currentNote!=▿ some : <Note: 0x600000af5380>
            if let position = self.data.firstIndex(of: note){
                
                //self.writeToFile()
                self.saveToCoreData()
                
                
                //組成 indexPath物件
                let indexPath = IndexPath(row: position, section: 0)
                //通知TableView reload特定位置的cell
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = NSLocalizedString("list", comment: "aaac")
        self.tableView.rowHeight = 70

        //iOS 11以上的環境才會執行
        if #available(iOS 11.0, *){
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        //利用系統提供的編輯按鈕
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //admob
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner) //設定banner大小
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.adUnitID = "ca-app-pub-4880651604060982/6754561833" //橫幅廣告id
        self.bannerView.delegate = self
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        //search
        self.searchController = UISearchController(searchResultsController: nil)
//        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
//        self.searchController.searchResultsUpdater = self
//        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search text"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        if data.count > 0 {
            for i in 0...data.count - 1{
                let note = data[i]
                guard let noteText = note.text else {return}
                dataStringArray.append(noteText)
            }
        }
    }

    //廣告進來時會呼叫,GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        //self.tableView.tableHeaderView = self.bannerView
        if self.bannerView.superview == nil{ //如果廣告還沒貼上
            self.topConstraint.isActive = false //關閉原本tableview上方的條件 (safeArea)
            self.view.addSubview(self.bannerView)

            //autolayout
            self.bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
            self.bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            self.bannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            self.bannerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
            //bannerview下方黏在tableview上方

        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)//一定要呼叫super
        self.tableView.setEditing(editing, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //SKStoreReviewController.requestReview()//是否評分APP,app內建的
        askForRating()
        /*
         let alert = UIAlertController(title: "請登入", message: "輸入帳號密碼", preferredStyle: .alert)
         
         alert.addTextField { (textField) in
         textField.placeholder = "請輸入帳號"
         }
         alert.addTextField { (textField) in
         textField.placeholder = "請輸入密碼"
         }
         
         let okAction = UIAlertAction(title: "登入", style: .default) { (action) in
         let account =  alert.textFields?[0].text
         let password = alert.textFields?[1].text
         UserDefaults.standard.synchronize()//強迫UserDefaults寫入到檔案(馬上儲存)
         
         }
         
         alert.addAction(okAction);
         self.present(alert, animated: true, completion: nil)
         */
        
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResult.count
        }else{
            return self.data.count
        }
    }
    
        

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //每一筆長的什麼像什麼樣子，回傳cell物件，如果回傳有10筆（self.data.count），這方法會被呼10次
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")//舊的作法
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)//storyboard作法 「留意」：noteCell 一定要定義在storyboard上
        let note = self.data[indexPath.row]//如果傳入的位置是(s:0,row:0)，那就取self.data[0]
        if isSearching {
            cell.textLabel?.text = searchResult[indexPath.row]
        }else{
            let note = data[indexPath.row]
            cell.textLabel?.text = note.text
        }
        //let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! NoteCell//子類別，多型
//        if (searchController.isActive) {
//            cell.textLabel?.text = searchResult[indexPath.row].text
//            if searchResult[indexPath.row].imageName != nil {
//                cell.imageView?.image = searchResult[indexPath.row].thumbnailImage()
//            }else{
//                cell.imageView?.image = UIImage(named: "dog-park-100.png")
//            }
//            cell.showsReorderControl = true
//            cell.selectedBackgroundView?.backgroundColor = .blue
//            cell.detailTextLabel?.text = searchResult[indexPath.row].date
//            return cell
//        }
        
        cell.textLabel?.text = note.text
        if note.imageName != nil {
            cell.imageView?.image = note.thumbnailImage()
        }else{
            cell.imageView?.image = UIImage(named: "dog-park-100.png")
        }
        cell.showsReorderControl = true
        cell.selectedBackgroundView?.backgroundColor = .blue
//        cell.imageView?.image = note.thumbnailImage()
        //cell.myLabel?.text = note.text
        
        cell.showsReorderControl = true
        //cell.accessoryType = .disclosureIndicator
        //cell.accessoryView = UISwitch()
        
        
        cell.detailTextLabel?.text = note.date

//        let now = Date()
//        cell.detailTextLabel?.text = DateFormatter.localizedString(from: now, dateStyle: .medium, timeStyle: .short)
        
//        let dataformatter = DateFormatter()
//        let calendar = Calendar(identifier: .republicOfChina) //民國
//        //let calendar = Calendar(identifier: .chinese) //農民歷
//        dataformatter.calendar = calendar //沒有設定日曆,會以手機的為主,通常是西歷
//        dataformatter.dateStyle = .long
//        dataformatter.timeStyle = .short
//        cell.detailTextLabel?.text = dataformatter.string(from: now)
//        note.date = cell.detailTextLabel?.text
        
//        cell.detailTextLabel?.text = NumberFormatter.localizedString(from: 1234.56, number: .currencyAccounting)
//
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //先處理model ( self.data）中的資料
            //P.320 Core Data Delete
            let data = self.data.remove(at: indexPath.row)
            let moc = CoreDataHelper.shared.managedObjectContext()
            moc.performAndWait {  //
                moc.delete(data)//從資料庫中刪除
            }
            //儲存
            self.saveToCoreData()
            
            //self.writeToFile()
            
            //通知tableView進行畫面更新
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //呼叫時，畫面已經換好位置了，處理相對應陣列中Note中的位置
        //先把note從原本位置移出來，再塞到新的位置
        let note = self.data.remove(at: sourceIndexPath.row)
        self.data.insert(note, at: destinationIndexPath.row)
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(indexPath.row)")
        //let cell = tableView.cellForRow(at: indexPath)
        //cellForRow 如果該位置的cell如果在畫面上，則回傳該cell，如果不在畫面上，回傳nil
        //print(cell?.isSelected)//true，cell灰色的
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        /*
         //透過storyboard把下一組畫面NoteViewController產生出來,不要跟storybaord機制混用
         if let noteVC =  self.storyboard?.instantiateViewController(withIdentifier: "noteVC"){
         self.navigationController?.pushViewController(noteVC, animated: true)
         //self.show(noteVC, sender: self)
         }
         */
        
        
    }
    /*
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     if indexPath.row % 2 == 1{
     return 50
     }
     return 100
     }
     */
    
    func loadFromFile(){
        //檔案載入self.data
        let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("notes.archive")//（副）檔名可以隨便取
        do {
            
            let data = try Data(contentsOf: fileURL)//取回Data
            if let arrayData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Note]{
                //如果檔案解回來可以正確轉成[Note],就放在self.data上
                self.data = arrayData
            }else{
                //如果檔案中不是[Note]，則用空Array
                self.data = []
            }
        }catch{
            print("error while transfering file to self.data \(error)")
        }
    }
    func writeToFile() {
        //self.data->檔案
        //先有路徑. Documents下notes.archive
        let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("notes.archive")//（副）檔名可以隨便取
        do {
            let data =  try NSKeyedArchiver.archivedData(withRootObject: self.data, requiringSecureCoding: false)//轉成Data型式
            try data.write(to: fileURL, options: .atomicWrite) //寫入檔案
        }catch{
            print("error while saving self.data \(error)")
        }
        
    }
    
    //MARK: Core Data
    func loadFromCoreData() {
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        //predicate範例
        //let predicate = NSPredicate(format: "text contains[cd] %@", "Note")//like
        //let predicate = NSPredicate(format: "text like %@", "*Note*")//like
        //fetchRequest.predicate = predicate
//        //排序
//        let sort = NSSortDescriptor(key: "text", ascending: true)//根據text欄位排序，由小到大
//        fetchRequest.sortDescriptors = [sort]
        let sortDescriptor = NSSortDescriptor(key: "coreDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        moc.performAndWait {
            do{
                let result = try moc.fetch(fetchRequest)//查詢Note table
                self.data = result
                
            }catch{
                print("error while fetching Note from db \(error)")
                self.data = []
            }
        }
    }
    
    func saveToCoreData(){
        CoreDataHelper.shared.saveContext()
    }
    
    
    @IBAction func edit(_ sender: Any) {
        //第一次點，self.tableView.isEditing ＝ false
        //self.tableView.isEditing = true
        //第二次self.tableView.isEditing ＝ true
        //self.tableView.isEditing = !self.tableView.isEditing
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
    }
    
    @IBAction func addNote(_ sender: Any) {
        
        Analytics.logEvent("addNote", parameters: nil)
        Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [AnalyticsParameterPrice: 1.0,
            AnalyticsParameterQuantity: 1,
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterValue: 2 ])
        let moc = CoreDataHelper.shared.managedObjectContext()
        let note = Note(context: moc)
        note.text = NSLocalizedString("new.note", comment: "aa")
        //新增到最後一筆
        //self.data.append(note) //model中要先新增一筆資料(Note物件), 總共11筆
        //step2. 通知tableView，畫面要新增一筆
        //第一個參數是位置IndexPath陣列，第二個參數是動畫
        //let indexPath = IndexPath(row: self.data.count-1, section: 0)//畫面上index =10
        
        //新增至第一筆
        self.data.insert(note, at: 0)//array中的位置
        //self.writeToFile()
        let now = Date()
        note.date = DateFormatter.localizedString(from: now, dateStyle: .full, timeStyle: .short)
        note.coreDate = now
        self.saveToCoreData()
        
        let indexPath = IndexPath(row: 0, section: 0)//畫面上index =10
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "noteVCSegue"{
            //切到NoteViewController
            let noteVC = segue.destination as! NoteViewController
            //透過indexPathForSelectedRow,取得使用者選到的位置
            if let indexPath = self.tableView.indexPathForSelectedRow{
                //取得陣列中相對應位置的Note物件
                let note = self.data[indexPath.row]
                //傳到下一個畫面去
                noteVC.currentNote = note
                noteVC.delegate = self//Any
            }
        }
    }
    //被NoteViewController呼叫
    func didFinishUpdate(note : Note){
        print("test 被呼叫")
        if let index = self.data.firstIndex(of: note){
            
            //self.writeToFile()
            self.saveToCoreData()
            
            
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    //詢問評分APP
    @IBAction func askForRating(){
        
        let askController = UIAlertController(title: "Hello App User",
                                              message: "If you like this app,please rate in App Store. Thanks.",
                                              preferredStyle: .alert)
        let laterAction = UIAlertAction(title: "稍候再評",
                                        style: .default, handler: nil)
        askController.addAction(laterAction)
        let okAction = UIAlertAction(title: "我要評分", style: .default)
        { (action) -> Void in
            let appID = "12345"
            let appURL =
                URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appID)?action=write-review")!
            UIApplication.shared.open(appURL, options: [:],
                                      completionHandler: { (success) in
            })
        }
        askController.addAction(okAction)
        self.present(askController, animated: true, completion: nil)
        
    }
    
    //寄送email
    @IBAction func support(){
        
        if ( MFMailComposeViewController.canSendMail()){
            let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English", preferredStyle: .alert)
            let email = UIAlertAction(title: "email", style: .default, handler: { (action) -> Void in
                let mailController =  MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.title = "I have question"
                mailController.setSubject("I have question")
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                mailController.setMessageBody(messageBody, isHTML: true)
                mailController.setToRecipients(["support@yoursupportemail.com"])
                self.present(mailController, animated: true, completion: nil)
            })
            alert.addAction(email)
            self.present(alert, animated: true, completion: nil)
        }else{
            //alert user can't send email
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch (result){
        case MFMailComposeResult.cancelled:
            print("user cancelled")
        case MFMailComposeResult.failed:
            print("user failed")
        case MFMailComposeResult.saved:
            print("user saved email")
        case MFMailComposeResult.sent:
            print("email sent")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
extension Notification.Name{
    static let noteUpdated = Notification.Name("noteUpdated")
}
//NSFetchedResultsControllerDelegate,UISearchControllerDelegate
extension ListViewController: UISearchBarDelegate {
//    func updateSearchResults(for searchController: UISearchController) {
////        if let searchText = searchController.searchBar.text{
////            filterContent(searchText: searchText)
////            tableView.reloadData()
////        }
//    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResult = dataStringArray.filter({ $0.prefix(searchText.count) == searchText})
        isSearching = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchController.searchBar.text = ""
        tableView.reloadData()
    }
    
}










