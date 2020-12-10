//
//  AppDelegate.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 8. 23..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
                
        UIApplication.shared.statusBarStyle = .lightContent
        
        //상태바가 표시되면 핫스팟 알림의 경우 아이콘 이미지가 납작하게 보이는 이슈가 있어 처음엔 상태바를 표시하지 않게 처리        
        UIApplication.shared.isStatusBarHidden = false
        
        //Google Map
        GMSServices.provideAPIKey("AIzaSyDz4c2U4b2Bur2B6nNygQBtZzaEfGueFYI")
        
       
        // Admob
        GADMobileAds.configure(withApplicationID: "ca-app-pub-7576584379236747~6363552704")
        
        return true
    }
    
   
   
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
}

