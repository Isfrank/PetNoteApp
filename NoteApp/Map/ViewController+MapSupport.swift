//
//  ViewController+MapSupport.swift
//  MyMap
//
//  Created by student46 on 2020/4/23.
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
        //as? MKPinAnnotationView//跑出出的reuse//animatesDrop,pinTintColor下面兒子才有所以要轉型
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
        
        let button = UIButton(type: .detailDisclosure)
        //touchUpInside:event 觸發 #selector：method
        button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        result?.rightCalloutAccessoryView =  button
        
        return result
        //有的話return
    }
    
    @objc func buttonPress(sender:Any){
        print("press")
        navigateTo(address: "台北市館前路45號")
        
    }
    func navigateTo(address:String){
        //異步執行 Async Task
        
        //Addeess -> Lat ,Lon
        let geocoder  = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            //有error就被擋
            if let error = error{
                print("geocodeArrressSting: \(error)")
                return
            }
//            if let placemark = placemarks?.first,
//                let coordinate = placemark.location?.coordinate{
//                print("Lat , Lon: \(coordinate.latitude), \(coordinate.longitude) ")
//            } else{
//                assertionFailure("Invalid placemark")
//                return
//            }
//        }
        guard let placemark = placemarks?.first,
            let coordinate = placemark.location?.coordinate else{
                assertionFailure("Invalid placemark")
                return
        }
        print("Lat , Lon: \(coordinate.latitude), \(coordinate.longitude) ")
            //Prepare source map item
            let sourceCoordinate = CLLocationCoordinate2D(latitude: 23.686525, longitude: 121.815312)
            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            
            
            //Prepare targer map item
            let targetPlaceMark = MKPlacemark(placemark: placemark)
            let targetMapItem = MKMapItem(placemark: targetPlaceMark)
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            targetMapItem.openInMaps(launchOptions: options)
            //sourceMapItem是起點, targerMapItem是終點
            MKMapItem.openMaps(with: [sourceMapItem, targetMapItem], launchOptions: options)
        }
 //Lat , Lon -> Address
        let gecoder2 = CLGeocoder()
        let homeLocation = CLLocation(latitude: 23.045164, longitude: 121.5151154)
        gecoder2.reverseGeocodeLocation(homeLocation) { (placemarks, error) in
            if let error = error{
                print("geocodeArrressSting: \(error)")
                return
            }
            guard let placemark = placemarks?.first,
                let coordinate = placemark.location?.coordinate else{
                    assertionFailure("Invalid placemark")
                    return
            }
            let description = placemark.description
            let postalCode = placemark.postalCode ?? "n/a"
            let countryCode = placemark.isoCountryCode ?? "n/a"
            print("\(description), \(postalCode), \(countryCode)")
        }
    }
}

