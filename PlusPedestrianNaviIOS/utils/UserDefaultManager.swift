//
//  UserDefault.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 11..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

//UserDefault(안드로이드의 SharedPreferences) 관리 
class UserDefaultManager {
    
    private static let KEY_CURRENT_MAP: String = "KEY_CURRENT_MAP";
    private static let KEY_USER_LOCATION: String = "KEY_USER_LOCATION";
       
    
    private static func saveString(key:String, value:String){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    private static func getString(key:String) -> String {
       let userDefaults = UserDefaults.standard
        if let value = userDefaults.value(forKey: key) as? String {
            return value
        } else {
            return ""
        }
    }
    
    private static func saveBool(key:String, value:Bool){
           let userDefaults = UserDefaults.standard
           userDefaults.setValue(value, forKey: key)
           userDefaults.synchronize()
       }
       
       private static func getBool(key:String) -> Bool {
          let userDefaults = UserDefaults.standard
           if let value = userDefaults.value(forKey: key) as? Bool {
               return value
           } else {
               return false
           }
       }
    
    private static func saveInt(key:String, value:Int){
           let userDefaults = UserDefaults.standard
           userDefaults.setValue(value, forKey: key)
           userDefaults.synchronize()
       }
       
       private static func getInt(key:String) -> Int {
          let userDefaults = UserDefaults.standard
           if let value = userDefaults.value(forKey: key) as? Int {
               return value
           } else {
               return 0
           }
       }
    
    private static func saveFloat(key:String, value:Float){
           let userDefaults = UserDefaults.standard
           userDefaults.setValue(value, forKey: key)
           userDefaults.synchronize()
       }
       
       private static func getString(key:String) -> Float {
          let userDefaults = UserDefaults.standard
           if let value = userDefaults.value(forKey: key) as? Float {
               return value
           } else {
               return 0
           }
       }
    
    private static func delete(key:String) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
    }
    
    
    public static func getCurrentMapOption() -> Int {
        return getInt(key: KEY_CURRENT_MAP)
    }
    
    public static func getUserLocation() -> Int {
        return getInt(key: KEY_USER_LOCATION)
    }
    
    public static func saveUserLocation(userLocation: Int) {
        saveInt(key: KEY_USER_LOCATION, value: userLocation)
    }
    
    public static func saveCurrentMapOption(mapOption: Int) {
           saveInt(key: KEY_CURRENT_MAP, value: mapOption)
       }
}

