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
}
