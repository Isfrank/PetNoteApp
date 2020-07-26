//
//  EGImageAnnotionView.swift
//  NoteApp
//
//  Created by Frank on 2020/6/13.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation
import MapKit

class EGImageAnnotionView: MKAnnotationView {
    
    init(annotation: MKAnnotation!, reuseIdentifier: String!, image: UIImage!) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier )
        
        self.frame = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)
        
        let imageView = UIImageView(image: image)
        
        self.addSubview(imageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
