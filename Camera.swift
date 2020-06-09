//
//  Date.swift
//  NoteApp
//
//  Created by student46 on 2020/6/9.
//  Copyright © 2020 Frank. All rights reserved.
//
/*
class camera{
    
}
func camera : UIImagePickerControllerDelegate,UINavigationControllerDelegate () {
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
    
}*/
