//
//  AppDelegate.swift
//  NoteApp
//
//  Created by Frank on 2020/6/16.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import UserNotifications
//import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

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
//        //fb登入
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // 在程式一啟動即詢問使用者是否接受圖文(alert)、聲音(sound)、數字(badge)三種類型的通知
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
            if granted {
                print("允許")
            } else {
                print("不允許")
            }
        })
        UNUserNotificationCenter.current().delegate = self
//        UIApplication.shared.applicationIconBadgeNumber = 0
        
        return true
    }
    //user登入成功後會來到這邊
//       func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//           //google的OC套件,管理google的登入
//           print("\(url)")
//           if let gidSignIn = GIDSignIn.sharedInstance(){
//               return gidSignIn.handle(url)
//           }
//           return false
//       }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           print("在前景收到通知...")
           completionHandler([.badge, .sound, .alert])
//            completionHandler([.sound, .alert])
       }
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }


}

