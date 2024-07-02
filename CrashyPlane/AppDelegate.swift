//
//  AppDelegate.swift
//  CrashyPlane
//
//  Created by Shubham Nanda on 13/06/24.
//

import UIKit
import GoogleMobileAds
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if UserDefaults.standard.object(forKey: "isSoundOn") == nil {
                   UserDefaults.standard.set(true, forKey: "isSoundOn")
               }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        BackgroundMusic.shared.stop()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundMusic.shared.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        BackgroundMusic.shared.play()
    }


}

