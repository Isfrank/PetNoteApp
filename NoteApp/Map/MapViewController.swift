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


class MapViewController: UIViewController, MKMapViewDelegate {
    //stored property -> instance
    let LocationManager = CLLocationManager()
    var nearbyAnnotations = [MKAnnotation]()
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    func mapThisRoute(){
        
    }
    @IBAction func modeChanged(_ sender: UISegmentedControl) {
        
        let targetIndex = sender.selectedSegmentIndex
        
        switch targetIndex {
            
        case 0:
           showNearBy(searchName: "寵物用品")
        case 1:
            showNearBy(searchName: "寵物餐廳")
        case 2:
            showNearBy(searchName: "公園")
        default:
            showNearBy(searchName: "寵物用品")
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
//

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
            if mapItems.count > 0{
                for item in mapItems{
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    
                    if let location = item.placemark.location{
                        annotation.coordinate = location.coordinate
                    }
                    self.nearbyAnnotations.append(annotation)
                }
            }
            self.mainMapView.showAnnotations(self.nearbyAnnotations, animated: true)
        }
    }
//    func updateSearchResults(for searchController: UISearchController) {
//        // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
//        searchCompleter?.queryFragment = searchController.searchBar.text ?? ""
//    }
}


