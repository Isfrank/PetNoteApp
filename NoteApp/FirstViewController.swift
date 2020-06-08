//
//  FirstViewController.swift
//  NoteApp
//
//  Created by student46 on 2020/5/28.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PetTableViewControllerdelegate {
    
    var data : [Pet] = [] //model:資料用Array來裝，裡面只能放Pet類型的物件
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var bdLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    var isNewImage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        pieChartView.slices = [
                          Slice(percent: 0.4, color: UIColor.red),
                          Slice(percent: 0.3, color: UIColor.blue),
                          Slice(percent: 0.2, color: UIColor.purple),
                          Slice(percent: 0, color: UIColor.green)
                      ]
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        todayDate.text = formatter.string(from: now)
        let today = Date()
        print(today)
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        print(modifiedDate)
        // Do any additional setup after loading the view.
    }
    @IBAction func walkBtn(_ sender: Any) {
        self.dayLabel.text = "0"
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pieChartView.animateChart()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPet"{
            let showPV = segue.destination as? PetTableViewController
            showPV?.delegate = self
            }
        }
    func didFinishupdate(pet: Pet){
        self.petNameLabel.text = pet.petName
        self.bdLabel.text = pet.bdtext
        self.ageLabel.text = pet.age
        self.homeLabel.text = pet.hometext
        
        let userDefaults = UserDefaults(suiteName: "group.org.iiiedu.lab.NoteApp10.PetWidget")
        userDefaults?.set( self.bdLabel.text, forKey: "bdlabel")
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


