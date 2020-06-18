//
//  AppDelegate.swift
//  NoteApp
//
//  Created by Frank on 2020/4/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("home = \(NSHomeDirectory())")
        print("temp = \(NSTemporaryDirectory())")
        FirebaseApp.configure()//讓GoogleService-Info.plist
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        //print(UserDefaults.standard.string(forKey: "user-account"))
        //print(UserDefaults.standard.string(forKey: "user-password"))
        //googleMap Key
        GMSServices.provideAPIKey("AIzaSyAm4sqJZtXGSk2XVACeFTUjcb9WkcZLEfs")
        GMSPlacesClient.provideAPIKey("AIzaSyAm4sqJZtXGSk2XVACeFTUjcb9WkcZLEfs")
        
        
        return true
    }
    

}

