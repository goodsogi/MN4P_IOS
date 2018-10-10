//
//  UserDefault.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 11..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation

//UserDefault(안드로이드의 SharedPreferences) 관리 
class UserDefault{
    class func save(key:String, value:String){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    class func load(key:String) -> String {
       let userDefaults = UserDefaults.standard
        if let value = userDefaults.value(forKey: key) as? String {
            return value
        } else {
            return ""
        }
    }
    
    class func delete(key:String) {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: key)
    }
}

