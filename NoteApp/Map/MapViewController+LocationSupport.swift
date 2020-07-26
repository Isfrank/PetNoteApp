//
//  ViewController+LocationSupport.swift
//  NoteApp
//
//  Created by student46 on 2020/6/13.
//  Copyright © 2020 Frank. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


extension MapViewController : CLLocationManagerDelegate{
      //越新的location會放陣列的越後面,位置改變才會回報
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let coordinate = locations.last?.coordinate{
    //            print("Coordinate: \(coordinate.latitude ),\(coordinate.longitude)")
    //        }
//            let c = locations[0]
//            var nowUserLocation = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude)
//            //導航
//            let pstarCoor = CLLocationCoordinate2D(latitude: nowUserLocation.latitude, longitude: nowUserLocation.longitude)
//            let pstar = MKPlacemark(coordinate: pstarCoor)
//            let pendCoor = CLLocationCoordinate2D(latitude:  ?? 25.150931, longitude: yPosition ?? 121.772389)
            
            //original 用guard else let就不會一直像if縮排
            guard let coordinate = locations.last?.coordinate else{
                return
            }
            print("Use location Coordinate: \(coordinate.latitude ),\(coordinate.longitude)")
            
            DispatchQueue.once(token:"Co"){
                 addAnnoatation(coordinate: coordinate)
            }
            DispatchQueue.once(token:"moveRegion"){
                moveRegion(coordinate: coordinate)
            }
    }
    func moveRegion(coordinate : CLLocationCoordinate2D){
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mainMapView.setRegion(region, animated: false)
        showNearBy(searchName: "公園")
//        showNearBy(searchName: "寵物餐廳")
//        showNearBy(searchName: "公園")

        
    }
    
}
