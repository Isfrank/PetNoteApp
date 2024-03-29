//
//  Pet.swift
//  NoteApp
//
//  Created by student46 on 2020/5/28.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Pet: NSManagedObject{
    @NSManaged var petID: String
    @NSManaged var petName: String?
    @NSManaged var petimageName: String?
    @NSManaged var age: String?
    @NSManaged var bdtext: String?
    @NSManaged var hometext: String?
    @NSManaged var birthdayPicker :Date?
    @NSManaged var homePicker :Date?
    @NSManaged var lastwalkDate :Date?

    override func awakeFromInsert() {
        self.petID = UUID().uuidString
    }
    func petimage() -> UIImage?{
        
        if let fileName = self.petimageName {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            let documents = homeURL.appendingPathComponent("Documents")
            let fileURL = documents.appendingPathComponent(fileName)
            print("\(fileURL)")
            return UIImage(contentsOfFile: fileURL.path)//從檔案路徑載入UIImage, url.path轉成String型式的路徑
        }
        return nil
    }
    func thumbnailImage() -> UIImage?{
        if let image =  self.petimage() {
            
            let thumbnailSize = CGSize(width:80, height: 80); //設定縮圖大小
            let scale = UIScreen.main.scale //找出目前螢幕的scale，視網膜技術為2.0

            //產生畫布，第一個參數指定大小,第二個參數true:不透明（黑色底）,false表示透明背景,scale為螢幕scale
            UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
            
            //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
            //最小值MIN會變成UIViewContentModeScaleAspectFit
            let widthRatio = thumbnailSize.width / image.size.width;
            let heightRadio = thumbnailSize.height / image.size.height;
            
            let ratio = max(widthRatio,heightRadio);
            
            let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
            
            
            let circlePath = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
            circlePath.addClip()

            
            
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                width: imageSize.width,height: imageSize.height))
            //取得畫布上的縮圖
            let smallImage = UIGraphicsGetImageFromCurrentImageContext();
            //關掉畫布
            UIGraphicsEndImageContext();
            return smallImage
        }else{
            return nil;
        }
    }
    
}
