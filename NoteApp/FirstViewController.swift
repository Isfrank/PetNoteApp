//
//  FirstViewController.swift
//  NoteApp
//
//  Created by student46 on 2020/5/28.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PetTableViewControllerdelegate {
    
    var data : [Pet] = [] //model:資料用Array來裝，裡面只能放Pet類型的物件
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var bdLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var lastWalkDay: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    var birthdatPicker: Date?
    var homePicker: Date?
    let now = Date()
    
    var isNewImage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        addBtn.imageView?.contentMode = .scaleAspectFill
        pieChartView.slices = [
            Slice(percent: 0.4, color: UIColor.red),
            Slice(percent: 0.3, color: UIColor.blue),
            Slice(percent: 0.2, color: UIColor.purple),
            Slice(percent: 0, color: UIColor.green)
        ]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        todayDate.text = formatter.string(from: now)
        let today = Date()
        print(today)
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        print(modifiedDate)
        //query
        let request = NSFetchRequest<Pet>(entityName: "Pet")
        do{
            data = try CoreDataHelper.shared.managedObjectContext().fetch(request)
        }catch{
            print("error \(error)")
        }
    
        // Do any additional setup after loading the view.
    }
    @IBAction func walkBtn(_ sender: Any) {
        let pet = data[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        pet.lastwalkDate = now
        CoreDataHelper.shared.saveContext()
        //pet.lastwalkDate = now
        //        self.lastWalkDay.text = formatter.string(from: now)
        self.lastWalkDay.text = "0天沒散步"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pieChartView.animateChart()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPet"{
            let showPV = segue.destination as? PetTableViewController
            showPV?.delegate = self
//            showPV?.pet = self.data[0]
        }
    }
    func didFinishupdate(pet: Pet){
        self.petNameLabel.text = pet.petName
        self.bdLabel.text = pet.bdtext
        self.ageLabel.text = pet.age
        self.homeLabel.text = pet.hometext
        self.birthdatPicker = pet.birthdayPicker
        self.homePicker = pet.homePicker
        self.imageView.image = pet.petimage()
//        self.addBtn.imageView?.image = pet.petimage()
        let userDefaults = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
        userDefaults?.set( self.bdLabel.text, forKey: "bdlabel")
        CoreDataHelper.shared.saveContext()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var components = DateComponents()
        guard data.count > 0 else{
            print("Fail to birthdatPicker.")
            return
        }
        self.petNameLabel.text = data[0].petName
        //birthday
        guard let anniversary = data[0].birthdayPicker else{
            return
        }
        components.year = Calendar.current.component(.year, from: now)
        components.month = Calendar.current.component(.month, from: anniversary)
        components.day = Calendar.current.component(.day, from: anniversary)
        
        let thisYearBirthday = Calendar.current.date(from: components)!
        if  thisYearBirthday.compare(now) == ComparisonResult.orderedAscending {
            components.year = Calendar.current.component(.year, from: now) + 1
            if let nextYearBirthday = Calendar.current.date(from: components){
                let diffDateComponents = Calendar.current.dateComponents([.month,.day], from: now, to: nextYearBirthday)
                self.bdLabel.text = "距離生日還有\(String(describing: diffDateComponents.month!))個月" + "\(String(describing: diffDateComponents.day!))天"
            }
        }else{
            let diffDateComponents =  Calendar.current.dateComponents([.year,.month,.day], from:now, to: thisYearBirthday)
            self.bdLabel.text = " 距離生日還有\(String(describing: diffDateComponents.month!))個月" + "\(String(describing: diffDateComponents.day!))天"
        }
        //widget birthday label
        let userDefaults = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
        userDefaults?.set( self.bdLabel.text, forKey: "bdlabel")
        //how old
        let diffDateComponents = Calendar.current.dateComponents([.year,.month,.day], from: anniversary, to: now)
        self.ageLabel.text  = "今年\(String(describing: diffDateComponents.year!))歲"
        //home
        guard let homeanniversary = data[0].homePicker else{
            print("Fail to homePicker.")
            return
        }
        let homediffDateComponents = Calendar.current.dateComponents([.year,.month,.day], from: homeanniversary, to: now)
        
        self.homeLabel.text = "已經陪伴你\(String(describing: homediffDateComponents.year!))年" + "\(String(describing: homediffDateComponents.month!))個月" + "\(String(describing: homediffDateComponents.day!))天"
        //home widget
        userDefaults?.set( self.homeLabel.text, forKey: "homelabel")
        CoreDataHelper.shared.saveContext()
        //walk
        let pet = data[0]
        guard let walk = pet.lastwalkDate else {
            print("Fail to lastwalkDate.")
            return
        }
        let walkdiffDateComponents = Calendar.current.dateComponents([.month,.day], from: walk, to: now)
        self.lastWalkDay.text = "已經\(String(describing: walkdiffDateComponents.day!))天沒散步"
        //CoreDataHelper.shared.saveContext()
//        self.imageView.image = data.petimage()
    }
    @IBAction func camera(_ sender: Any) {
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        photoSourceRequestController.addAction(cancelAction)
        self.present(photoSourceRequestController, animated: true, completion: nil)
        //        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
        //            let imagePicker = UIImagePickerController()//內建裝置課程老師會再講
        //            imagePicker.sourceType = .savedPhotosAlbum //從相簿中選照片
        //            imagePicker.delegate = self
        //            self.present(imagePicker, animated: true, completion: nil)
        //        }
        //        if UIImagePickerController.isSourceTypeAvailable(.camera){
        //            let imagePicker = UIImagePickerController()
        //            imagePicker.sourceType = .camera
        //            imagePicker.delegate = self
        //            self.present(imagePicker, animated: true, completion: nil)
        //        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage//取得使用者選擇的照片
        self.imageView.image = image //放在imageView上
        self.isNewImage = true //表示使用者有選過新照片
        
        save(image: self.imageView.image)
        
        let path = NSHomeDirectory() + "/Documents/Main.jpg"
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let myUserDefault = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
            myUserDefault?.set(data, forKey: "image")
        }catch{
            print("error \(error.localizedDescription)")
        }
        self.dismiss(animated: true, completion: nil)//關閉UIImagePickerController
    }
    func save (image: UIImage?){
        let jpgData = image?.jpegData(compressionQuality: 0.8)
        
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            assertionFailure("Fail tp get documents url.")
            return
        }
        let finalUrl = url.appendingPathComponent("Main.jpg")
        do{
            try jpgData?.write(to: finalUrl)
        }catch{
            print(error.localizedDescription)
        }
    }
}
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


