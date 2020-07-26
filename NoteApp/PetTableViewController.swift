//
//  PetTableViewController.swift
//  NoteApp
//
//  Created by frank on 2020/5/27.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import CoreData

protocol PetTableViewControllerdelegate: class {
    func didFinishupdate(pet: Pet)
}

class PetTableViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var bdTextField: UITextField!
    @IBOutlet weak var homeTextField: UITextField!
   
    
    //    var data : [Pet] = [] //model:資料用Array來裝，裡面只能放Pet類型的物件
    var pet: Pet!
    weak var delegate: PetTableViewControllerdelegate!
    var formatter: DateFormatter! = nil
    let bddatePicker = UIDatePicker()
    let homedatePicker = UIDatePicker()
    let now = Date()
    var isNewImage : Bool = false
    
    @IBAction func imageBtn(_ sender: Any) {
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
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
        
    }
    let defaultImage = UIImage(systemName:"photo")
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.backgroundColor = UIColor.cyan
        nameTextField.delegate = self
        nameTextField.placeholder = "請輸入名字"
        bdTextField.delegate = self
//        self.bdTextField.placeholder
        homeTextField.delegate = self
        bddatePicker.maximumDate = Date()
        homedatePicker.maximumDate = Date()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap) // to Replace "TouchesBegan"
        
        //        let pickerView = UIPickerView()
        bddatePicker.datePickerMode = .date
        homedatePicker.datePickerMode = .date
        self.bdTextField.inputView = bddatePicker
        self.homeTextField.inputView = homedatePicker
        bddatePicker.reloadInputViews()
        homedatePicker.reloadInputViews()
        addDoneButtonOnKeyboard()
        photoImageView.isUserInteractionEnabled = true
        //edit
        
        if self.pet != nil {
            self.nameTextField?.text = self.pet.petName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: self.pet.birthdayPicker ?? now )
            self.bdTextField.text = dateString
            let bdtext = dateString
            self.bdTextField.text = "\(String(describing: bdtext))"
            let homedateString = dateFormatter.string(from: self.pet.homePicker ?? now )
            let hometext = homedateString
            self.homeTextField.text = "\(String(describing: hometext))"
            self.photoImageView.image = self.pet.petimage()
        }else{
            self.photoImageView.image = defaultImage
        }
//
    }
    @IBAction func Done(_ sender: Any) {
        
        if self.photoImageView.image == self.defaultImage || self.nameTextField.text?.isEmpty == true || self.bdTextField.text?.isEmpty == true || self.homeTextField.text?.isEmpty == true {
            
        let controller = UIAlertController(title: "不可以沒照片或有空格哦", message: "請輸入完成", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
            return
    }
        //edit
        if self.pet == nil {
            self.pet = Pet(context: CoreDataHelper.shared.managedObjectContext())
        }
        guard self.pet != nil else {
            fatalError("pet shouldn't be nil")
        }
        if self.isNewImage {
            //image寫到檔案中  c:\iOS\Documents\uuidxxxxxxx.jpg
            let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
            let documents = homeURL.appendingPathComponent("Documents") //取得Documents目錄位置
            
            let fileName = "\(self.pet.petID).jpg"
            
            let fileURL = documents.appendingPathComponent(fileName)// Documents/xxxx.jpg
            
            if let imageData = self.photoImageView.image?.jpegData(compressionQuality: 1){
                do {
                    try imageData.write(to: fileURL, options: [.atomicWrite])
                    self.pet.petimageName = fileName
                }catch{
                    print("error saving photo \(error)")
                }
            }
        }
        let now = Date()
        let anniversary = bddatePicker.date
        var components = DateComponents()
        //birthday
        self.pet.birthdayPicker = anniversary
        components.year = Calendar.current.component(.year, from: now)
        components.month = Calendar.current.component(.month, from: anniversary)
        components.day = Calendar.current.component(.day, from: anniversary)
        let thisYearBirthday = Calendar.current.date(from: components)!
        //今年生日比現在時間少
        if  thisYearBirthday.compare(now) == ComparisonResult.orderedAscending {
            components.year = Calendar.current.component(.year, from: now) + 1
            if let nextYearBirthday = Calendar.current.date(from: components){
                let diffDateComponents = Calendar.current.dateComponents([.month,.day], from: now, to: nextYearBirthday)
                self.pet.bdtext = "\(String(describing: diffDateComponents.month!))個月" + "\(String(describing: diffDateComponents.day!))天"
            }
        }else{
            let diffDateComponents =  Calendar.current.dateComponents([.year,.month,.day], from:now, to: thisYearBirthday)
            self.pet.bdtext = "\(String(describing: diffDateComponents.month!))個月" + "\(String(describing: diffDateComponents.day!))天"
        }
        //how old
        let diffDateComponents = Calendar.current.dateComponents([.year,.month,.day], from:anniversary , to: now)
        self.pet.age = "今年\(String(describing: diffDateComponents.year!))歲"
        //        timeIntervalDisplayLabel.text = "\(String(describing: diffDateComponents.year!))年" + " \(String(describing: diffDateComponents.month!))月" + " \(String(describing: diffDateComponents.day!))日"
        //home
        let homeanniversary = homedatePicker.date
        self.pet.homePicker = homeanniversary
        let homediffDateComponents = Calendar.current.dateComponents([.year,.month,.day], from: homeanniversary, to: now)
        
        self.pet.petName = self.nameTextField?.text
        
//        guard var bdpet = self.bdTextField.text else{return}
//        bdpet = "今年\(String(describing: diffDateComponents.year!))歲"
//        self.pet.bdtext = " 距離生日還有\(String(describing: diffDateComponents.month!))個月" + "\(String(describing: diffDateComponents.day!))天"
//        guard let homepet = self.homeTextField.text else{return}
        self.pet.hometext = "\(String(describing: homediffDateComponents.year!))年" + "\(String(describing: homediffDateComponents.month!))個月" + "\(String(describing: homediffDateComponents.day!))天"
        self.delegate.didFinishupdate(pet: self.pet)
        CoreDataHelper.shared.saveContext()
        self.dismiss(animated: true, completion: nil)
        
}
    //    MARK: DatePicker
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done,target: self,action: #selector(doneButtonAction))
        var items:[UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.bdTextField.inputAccessoryView = doneToolbar
        self.homeTextField.inputAccessoryView = doneToolbar
        
    }

    @objc func doneButtonAction() {
        
        if let datePickerView = self.bdTextField.inputView as? UIDatePicker, self.bdTextField.isFirstResponder {
            //if let datePickerView = self.bdTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.bdTextField.text = dateString
            self.bdTextField.resignFirstResponder()
            //            datePickerView.reloadInputViews()
        }
        //        guard homeTextField.text != nil else {return}
        if let datePickerView = self.homeTextField.inputView as? UIDatePicker, self.homeTextField.isFirstResponder {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.homeTextField.text = dateString
            self.homeTextField.resignFirstResponder()
        }
    }
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }
    // MARK: - Table view data source
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
        }
    }*/
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage{
            photoImageView.image = selectedImage
            let image = selectedImage
            let imageData = image.jpegData(compressionQuality: 32)
            self.isNewImage = true //表示使用者有選過新照片
            photoImageView.contentMode = .scaleToFill
            photoImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
    /*
     override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }*/
    /*
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 1
     }*/
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


