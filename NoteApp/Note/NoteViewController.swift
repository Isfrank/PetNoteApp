//
//  NoteViewController.swift
//  NoteApp
//
//  Created by Frank on 2020/4/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol NoteViewControllerDelegate : class {
    func didFinishUpdate(note : Note)
}


class NoteViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, GADInterstitialDelegate {
    
    var adView: GADInterstitial!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    var currentNote : Note!
    weak var delegate : NoteViewControllerDelegate?
    var isNewImage : Bool = false
    //條件改成：所有型態的物件都可以，但是他一定要有didFinishUpdate方法
    var imageHeighConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = self.currentNote.text
        self.imageView.image = self.currentNote.image()
        
        self.imageView.layer.borderWidth = 10
        self.imageView.layer.borderColor = UIColor.orange.cgColor
        //CG: Core Graphic是 UIKit的老爸
        self.imageView.layer.cornerRadius = 10
        //self.imageView.clipsToBounds = true
        //        self.imageView.layer.masksToBounds = true //等於self.imageView.clipsToBounds = true
        
        self.imageView.layer.shadowColor = UIColor.gray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
        //補上4:3條件，因為高度條件設成remove at build time
        
        self.imageHeighConstraint =  self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.75)
        //只有在R情況下，直向，才要把4：3條件設起來
        if self.traitCollection.verticalSizeClass == .regular {
            self.imageHeighConstraint.isActive = true
            
            self.adView = GADInterstitial(adUnitID: "ca-app-pub-4880651604060982/8595570196")
            self.adView.delegate = self
            self.adView.load(GADRequest())
        }
        
        print(self.toolbar.intrinsicContentSize)
    }
    //MARK:GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //使用者按下x
        self.navigationController?.popViewController(animated: true)
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        //使用者點選連結離開應用程式, 前往app store下載遊戲
        self.dismiss(animated: false) {
            self.navigationController?.popViewController(animated: false) //確定離開應用程式就不用動畫
        }
    }
    
    
    //旋轉時會被呼叫
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        //如果新的轉向垂直向（高度）是Regular 才需要4:3條件，否則就拿掉
        if newCollection.verticalSizeClass == .regular {
            self.imageHeighConstraint.isActive = true
        }else{
            self.imageHeighConstraint.isActive = false
        }
    }
    
    @IBAction func done(_ sender: Any) {
        
        self.currentNote.text = self.textView.text
        //self.currentNote.image = self.imageView.image
        
        if self.isNewImage {
            //image寫到檔案中  c:\iOS\Documents\uuidxxxxxxx.jpg
            let homeURL = URL(fileURLWithPath: NSHomeDirectory()) //取得Sandbox
            let documents = homeURL.appendingPathComponent("Documents") //取得Documents目錄位置
            
            let fileName = "\(self.currentNote.noteID).jpg"
            
            let fileURL = documents.appendingPathComponent(fileName)// Documents/xxxx.jpg
            
            if let imageData = self.imageView.image?.jpegData(compressionQuality: 1){
                do {
                    try imageData.write(to: fileURL, options: [.atomicWrite])
                    self.currentNote.imageName = fileName
                }catch{
                    print("error saving photo \(error)")
                }
            }
        }
        self.delegate?.didFinishUpdate(note: self.currentNote)
        
        //回到前一頁
        if adView.isReady{
            //顯示廣告
            self.adView.present(fromRootViewController: self)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
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
        
        // todo NSPhotoLibraryUsageDescription in the info.plist
        //        let imagePicker = UIImagePickerController()//內建裝置課程老師會再講
        //        imagePicker.sourceType = .savedPhotosAlbum //從相簿中選照片
        //        imagePicker.delegate = self
        //        self.present(imagePicker, animated: true, completion: nil)//跳出選照片Controller
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage//取得使用者選擇的照片
        self.imageView.image = image //放在imageView上
        
        self.isNewImage = true //表示使用者有選過新照片
        
        self.dismiss(animated: true, completion: nil)//關閉UIImagePickerController
        //picker.dismiss(animated: true, completion: nil)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
