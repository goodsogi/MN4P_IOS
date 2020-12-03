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
    
    private static let KEY_CURRENT_MAP: String = "KEY_CURRENT_MAP"
    private static let KEY_USER_LOCATION: String = "KEY_USER_LOCATION"
    private static let KEY_IS_HOME_SET: String = "KEY_IS_HOME_SET"
    private static let KEY_IS_WORK_SET: String = "KEY_IS_WORK_SET"
    public static let KEY_HOME_NAME: String = "KEY_HOME_NAME"
    public static let KEY_HOME_ADDRESS: String = "KEY_HOME_ADDRESS"
       public static let KEY_HOME_BIZNAME: String = "KEY_HOME_BIZNAME"
       public static let KEY_HOME_LATITUDE: String = "KEY_HOME_LATITUDE"
       public static let KEY_HOME_LONGITUDE: String = "KEY_HOME_LONGITUDE"
       public static let KEY_HOME_PHONE: String = "KEY_HOME_PHONE"
       public static let KEY_HOME_DISTANCE: String = "KEY_HOME_DISTANCE"
       public static let KEY_WORK_NAME: String = "KEY_WORK_NAME"
    public static let KEY_WORK_ADDRESS: String = "KEY_WORK_ADDRESS"
       public static let KEY_WORK_BIZNAME: String = "KEY_WORK_BIZNAME"
       public static let KEY_WORK_LATITUDE: String = "KEY_WORK_LATITUDE"
       public static let KEY_WORK_LONGITUDE: String = "KEY_WORK_LONGITUDE"
       public static let KEY_WORK_PHONE: String = "KEY_WORK_PHONE"
       public static let KEY_WORK_DISTANCE: String = "KEY_WORK_DISTANCE"
       public static let KEY_IS_FROM_SETTING_FRAGMENT: String = "KEY_IS_FROM_SETTING_FRAGMENT"
       public static let KEY_IS_FROM_SET_POINT_FRAGMENT: String = "KEY_IS_FROM_SET_POINT_FRAGMENT"
    
    
    private static func saveString(key:String, value:String){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    private static func getString(key:String, defaultValue:String) -> String {
       let userDefaults = UserDefaults.standard
        if let value = userDefaults.value(forKey: key) as? String {
            return value
        } else {
            return defaultValue
        }
    }
    
    private static func saveBool(key:String, value:Bool){
           let userDefaults = UserDefaults.standard
           userDefaults.setValue(value, forKey: key)
           userDefaults.synchronize()
       }
       
    private static func getBool(key:String, defaultValue:Bool) -> Bool {
          let userDefaults = UserDefaults.standard
           if let value = userDefaults.value(forKey: key) as? Bool {
               return value
           } else {
               return defaultValue
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
       
    private static func getFloat(key:String) -> Float {
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
    
    public static func isHomeSet() -> Bool {
        return getBool(key: KEY_IS_HOME_SET, defaultValue: false)
    }
    
    public static func isWorkSet() -> Bool {
        return getBool(key: KEY_IS_WORK_SET, defaultValue: false)
    }
    
    public static func saveIsFromSettingFragment(value: Bool) {
        saveBool(key: KEY_IS_FROM_SETTING_FRAGMENT, value: value)
    }
    
    public static func getHomeModel() -> PlaceModel {
        let name: String =  getString(key: KEY_HOME_NAME,defaultValue: "")
        let bizName: String =  getString(key: KEY_HOME_BIZNAME, defaultValue: "")
        let latitudeString: String =  getString(key: KEY_HOME_LATITUDE,defaultValue: "0")
        let latitude: Double = NumberFormatter().number(from: latitudeString)!.doubleValue
        let longitudeString: String =  getString(key: KEY_HOME_LONGITUDE,defaultValue: "0")
        let longitude: Double = NumberFormatter().number(from: longitudeString)!.doubleValue
        
        let address: String =  getString(key: KEY_HOME_ADDRESS,defaultValue: "")
        let telNo: String =  getString(key: KEY_HOME_PHONE,defaultValue: "")
        let distanceString: String =  getString(key: KEY_HOME_DISTANCE,defaultValue: "0")
        let distance: Int = NumberFormatter().number(from: distanceString)!.intValue
        
        
        let placeModel: PlaceModel = PlaceModel();
        placeModel.setName(name: name);
               placeModel.setBizname(bizName:bizName);
        placeModel.setLatitude(latitude: latitude);
        placeModel.setLongitude(longitude: longitude);
        placeModel.setAddress(address: address);
        placeModel.setTelNo(telNo: telNo);
        placeModel.setDistance(distance: distance);
               return placeModel;
    }
}

