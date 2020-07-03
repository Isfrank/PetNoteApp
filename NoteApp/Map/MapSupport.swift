//
//  MapSupport.swift
//  NoteApp
//
//  Created by student46 on 2020/7/3.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation
import MapKit
//user縮放地圖
extension MapViewController: MKMapViewDelegate{
    //地圖應該如何顯示
    //(_ mapView)他自己 mainMapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseID = "store"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
//        as? MKPinAnnotationView//跑出出的reuse//animatesDrop,pinTintColor下面兒子才有所以要轉型
        if result == nil{
            
            //Creat Pin
            //result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
        }
        result?.canShowCallout = true
        //result?.animatesDrop = true
        //result?.pinTintColor = .green
        let image = UIImage(named: "pointRed")
        result?.image = image
        
        let imageView = UIImageView(image: image)
        result?.leftCalloutAccessoryView = imageView
        
//        let button = UIButton(type: .detailDisclosure)
//        //touchUpInside:event 觸發 #selector：method
//        button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
//        result?.rightCalloutAccessoryView =  button
//        
        return result
        //有的話return
    }
