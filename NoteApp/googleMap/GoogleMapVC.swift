//
//  GoogleMapVC.swift
//  NoteApp
//
//  Created by student46 on 2020/6/18.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class GoogleMapVC: UIViewController{
    
    var userLocation: CLLocation?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var textSearch: UITextField!
    var path: GMSMutablePath!
    @IBAction func loactionTapped(_ sender: Any) {
        gotoPlaces()
    }
    let key = "AIzaSyAm4sqJZtXGSk2XVACeFTUjcb9WkcZLEfs"
    override func viewDidLoad() {
        super.viewDidLoad()
        //Google maps sdk: Compass
        mapView.settings.compassButton = true
        //Google maps sdk User location
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
//        let url = URL(string: "comgooglemaps://?saddr=&daddr=25.033671,121.564427&directionsmode=driving")
//
//        if UIApplication.shared.canOpenURL(url!) {
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        } else {
//            // 若手機沒安裝 Google Map App 則導到 App Store(id443904275 為 Google Map App 的 ID)
//            let appStoreGoogleMapURL = URL(string: "itms-apps://itunes.apple.com/app/id585027354")!
//            UIApplication.shared.open(appStoreGoogleMapURL, options: [:], completionHandler: nil)
//        }
        
    }
    func gotoPlaces(){
        textSearch.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        var bounds: GMSCoordinateBounds = GMSCoordinateBounds()
//        for index in 0 ..< path.count() {
//            bounds = bounds.includingCoordinate(path.coordinate(at: index))
//        }
//        self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //userlocation
    func nearbyLocations(userLocation: CLLocation?) {
        
        guard let userLocation = userLocation else {
           print("No user")
            return
        }
        
       let jsonUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&radius=1500&type=pet_store&keyword=pet&key=\(key)"

        guard let url = URL(string: jsonUrlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let root = try decoder.decode(PetSearch.self, from: data)
                //var cafeCountIndex = root.results.count - 1
                print(root)
                for index in 0...root.results.count - 1 {
                    print("AAA: \(root.results[index].name)")
                }
                print("root.results.count: \(root.results.count)")
                //print(cafeCountIndex)
                print(root.results.first?.name ?? -1)
                print(root.results.first?.icon ?? -1)
                print(root.results)
               
                DispatchQueue.main.async {
    //                self.search.text = "Name: \(root.results[3].name) + PlaceID: \(root.results[3].placeId) + OpeningHours: \(String(describing: root.results[3].openingHours?["open_now"]!) )"
                }
                
            } catch  {
                print("Fail to root: \(error)")
            }
        }.resume()
    }
}

extension GoogleMapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //search
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else{return}
        print("locations: \(locValue.latitude) \(locValue.longitude)")
        //userlocation
        guard let userlocation = locations.first else{return}
        print("userlocation:\(userlocation)")
        print("userlocation latitude: \(userlocation.coordinate.latitude)")
        print("userlocation longitude: \(userlocation.coordinate.longitude)")

    }
}
extension GoogleMapVC: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name:\(String(describing: place.name))")
        dismiss(animated: true, completion: nil)
        
        self.mapView.clear()
        self.textSearch.text = place.name
        
        let core2D = CLLocationCoordinate2D(latitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude))
        let marker = GMSMarker()
        marker.position = core2D
        marker.title = "Location"
        marker.snippet = place.name
        
        let markerImage = UIImage(named: "Icon_offer_pickup")
        let markerView = UIImageView(image: markerImage)
        marker.iconView = markerView
        marker.map = self.mapView
        
        self.mapView.camera = GMSCameraPosition.camera(withTarget: core2D, zoom: 15)
        //path
        self.path = GMSMutablePath()
        self.path.add(CLLocationCoordinate2D(latitude:25.033671, longitude: 121.564427))
//        self.path.add(core2D)
        self.path.add(CLLocationCoordinate2D(latitude:25.0326708, longitude: 121.56953640000006))
        
        let line = GMSPolyline(path: self.path)
        line.map = self.mapView
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
