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
class GoogleMapVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var textSearch: UITextField!
    @IBAction func loactionTapped(_ sender: Any) {
        gotoPlaces()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Google maps sdk: Compass
        mapView.settings.compassButton = true
        //Google maps sdk User location
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    func gotoPlaces(){
        textSearch.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension GoogleMapVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else{return}
        print("locations: \(locValue.latitude) \(locValue.longitude)")
        

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
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
