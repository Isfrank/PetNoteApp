//
//  Note.swift
//  NoteApp
//
//  Created by Frank on 2020/4/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//class Note : Equatable { //step1
//class Note : NSObject, NSCoding { //Archiving
class Note : NSManagedObject {
    //JSON <-> Note
    
    override func awakeFromInsert() {
        //產生Note物件時，會被呼叫
        self.noteID = UUID().uuidString//從init搬過來
    }
    
    /*
    override init() {
          self.noteID = UUID().uuidString //產生隨機的亂碼 32
    }
    func encode(with coder: NSCoder) {
        
        coder.encode(self.text, forKey: "text")
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.noteID, forKey: "noteID")
    }
    
    required init?(coder: NSCoder) {
        
        self.noteID = coder.decodeObject(forKey: "noteID") as! String
        self.text = coder.decodeObject(forKey: "text") as? String
        self.imageName = coder.decodeObject(forKey: "imageName") as? String

    }
    */
    
    //self.data.firstIndex(of: note)
    static func == (lhs: Note, rhs: Note) -> Bool {
        //判斷兩個Note物件，怎麼樣才做叫相等
        return lhs.noteID == rhs.noteID
        //return lhs === rhs
    }
    
    @NSManaged var noteID : String //id一定要有，所以沒有用optional
    @NSManaged var text : String? //文字可能為空白，用optional
    @NSManaged var imageName : String?//照片檔名（noteID.jpg or ni)
    @NSManaged var date : String?//照片檔名（noteID.jpg or ni)
    @NSManaged var coreDate : Date?//照片檔名（noteID.jpg or ni)

    //var image : UIImage?//image可能為空的，用optional
    
    
    //從檔案中讀取圖片轉成UIImage
    func image() -> UIImage?{
        
        if let fileName = self.imageName {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            let documents = homeURL.appendingPathComponent("Documents")
            let fileURL = documents.appendingPathComponent(fileName)
            print("\(fileURL)")
            return UIImage(contentsOfFile: fileURL.path)//從檔案路徑載入UIImage, url.path轉成String型式的路徑
        }
        return nil
    }
    
    //產生縮圖, 50x50縮圖
    func thumbnailImage() -> UIImage?{
        if let image =  self.image() {
            
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
