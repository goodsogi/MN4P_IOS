//
//  UserInfoManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 13/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//
import UIKit
import CoreLocation

public class UserInfoManager {
    
    public static let KOREA: Int = 0;
    public static let OVERSEA: Int = 0;
    
    public static func isLanguageKorean() -> Bool {
       let languageCode = Locale.current.languageCode
        //문자열이 같은지 비교 ==
        return languageCode == "ko"
    }
    
    public static func isUserInKorea() -> Bool {
        return UserDefaultManager.getUserLocation() == KOREA
    }
 
    public static func setUserLocation(userLocation:CLLocation?) {
        //TODO: 주석풀고 구현하세요
        //let countryName = AddressManager.getCountry(userLocation: userLocation)
        
        //if (countryName == nil || countryName == "") {
         //   return
        //}
        
        //let userLocationInt = (countryName.contains("대한민국") || countryName.contains("South Korea")) ? KOREA: OVERSEA
       // UserDefaultManager.saveUserLocation(userLocation: userLocationInt)
       }
    
}
