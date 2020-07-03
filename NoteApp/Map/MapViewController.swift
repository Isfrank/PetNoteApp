//
//  ViewController.swift
//  MyMap
//
//  Created by Frank on 2020/4/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit


class MapViewController: UIViewController {
    //stored property -> instance
    let LocationManager = CLLocationManager()
    var nearbyAnnotations = [MKAnnotation]()
    @IBOutlet weak var mainMapView: MKMapView!
    var nearByPointAnnotation: MKPointAnnotation!
    var nearByItem: [MKMapItem]!
    var selectedAnnotation: MKPointAnnotation!
    
    //自己發明的 把圖標放在哪個經緯度
    //儲存屬性是比較重要的,用struct,一樣的東西struct運行速度是class的10倍
    //coordinate是let
    func addAnnoatation(coordinate:CLLocationCoordinate2D){
        
        var annotationCoordinate = coordinate
        annotationCoordinate.latitude += 0.0001
        annotationCoordinate.longitude += 0.0001
        
        //蘋果設計好的圖標,儲存關於這個圖標的相關資料,是資料物件
        //annotation是reference type 所以用let
        //計算的或要可以繼承用class(耗費的資源會比較大)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationCoordinate //座標放進去
//        annotation.title = "肯德基"
//        annotation.subtitle = "真好吃"
        
        mainMapView.addAnnotation(annotation)
    }
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        let targetIndex = sender.selectedSegmentIndex
        
        switch targetIndex {
            
        case 0:
           showNearBy(searchName: "公園")
        case 1:
            showNearBy(searchName: "寵物餐廳")
        case 2:
            showNearBy(searchName: "寵物用品")
        case 3:
            showNearBy(searchName: "動物醫院")
        default:
            showNearBy(searchName: "公園")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //定位是否有開 沒開return提示給他 , Class method , Class function, 用一下就不用了就不用new一個物件, 全域
//        mainMapView.delegate = self
        guard CLLocationManager.locationServicesEnabled()else{
            return
        }
        // Ask permission
        //LocationManager.requestWhenInUseAuthorization()
        //Instance method, instance function 實例, 實體
        LocationManager.requestAlwaysAuthorization()
        //精確度到什麼程度,ios盡力達到
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        //app活動的種類 (車輛導航 單車)不指定就是other
        LocationManager.activityType = .automotiveNavigation
        LocationManager.delegate = self
        LocationManager.startUpdatingLocation()
        LocationManager.allowsBackgroundLocationUpdates = true
        mainMapView.delegate = self
        //MKDirections Request
    }
    //背景執行關閉定位功能
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.stopUpdatingLocation()
        
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
           renderer.strokeColor = UIColor.blue
           return renderer
       }
    func showNearBy(searchName: String){
        self.nearbyAnnotations = []
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchName
        searchRequest.region = mainMapView.region
        
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { (response, error) in
            guard let response = response else{
                if let error = error{
                print(error)
                }
                return
            }
            let mapItems = response.mapItems
            self.nearByItem = mapItems
            if mapItems.count > 0{
                for item in mapItems{
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    
                    if let location = item.placemark.location{
                        annotation.coordinate = location.coordinate
                        self.nearByPointAnnotation = annotation
                    }
                    self.nearbyAnnotations.append(annotation)
                    
                }
            }
            self.mainMapView.removeAnnotations(self.mainMapView.annotations)
            //self.mainMapView.showAnnotations(self.nearbyAnnotations, animated: true)
            self.mainMapView.addAnnotations(self.nearbyAnnotations)
        }
    }
//    func updateSearchResults(for searchController: UISearchController) {
//        // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
//        searchCompleter?.queryFragment = searchController.searchBar.text ?? ""
//    }
}
extension MapViewController: MKLocalSearchCompleterDelegate{
}
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseID = "store"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        as? MKPinAnnotationView//跑出出的reuse//animatesDrop,pinTintColor下面兒子才有所以要轉型
        if result == nil{
            
            //Creat Pin
            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
//            result = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
        }
        result?.canShowCallout = true
        result?.animatesDrop = true
        result?.pinTintColor = .black
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation as? MKPointAnnotation
//        print("\(selectedAnnotation.coordinate)")
//        print("\(selectedAnnotation.title)")
    }
    @objc func buttonPress(sender:Any){
        
//        let sourceCoordinate = CLLocationCoordinate2D(latitude: (selectedAnnotation?.coordinate.latitude)! , longitude: (selectedAnnotation?.coordinate.longitude)!)
        //導航
        let sourceCoordinate = CLLocationCoordinate2D(latitude: selectedAnnotation.coordinate.latitude, longitude: selectedAnnotation.coordinate.longitude)
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        sourceMapItem.name = self.selectedAnnotation.title
        let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        sourceMapItem.openInMaps(launchOptions: options)
        
        
        
        
//        print("press")
////        navigateTo(address: "台北市館前路45號")
//        let gecoder2 = CLGeocoder()
//
//        if nearByItem.count > 0{
//            for item in nearByItem{
//                let annotation = MKPointAnnotation()
//                annotation.title = item.name
//                annotation.subtitle = item.phoneNumber
//
//                if let location = item.placemark.location{
//                    annotation.coordinate = location.coordinate
//
//                    let nearByLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//
//                    gecoder2.reverseGeocodeLocation(nearByLocation) { (placemarks, error) in
//                        if let error = error{
//                            print("geocodeArrressSting: \(error)")
//                            return
//                        }
//                        guard let placemark = placemarks?.first,
//                            let coordinate = placemark.location?.coordinate else{
//                                assertionFailure("Invalid placemark")
//                                return
//                        }
//                        if annotation.title == placemark.name{
//                        let description = placemark.description
//                        let postalCode = placemark.postalCode ?? "n/a"
//                        let countryCode = placemark.isoCountryCode ?? "n/a"
//                        print("\(description), \(postalCode), \(countryCode)")
//
//                        self.navigateTo(address: "\(placemark.description)")
//                    }
//                }
//        navigateTo(address: "\(self.nearbyAnnotations.description)")
//        }
//    }
//}
    }
    func navigateTo(address: String){
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


