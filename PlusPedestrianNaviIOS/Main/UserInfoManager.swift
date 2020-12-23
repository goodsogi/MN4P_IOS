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
        //PROJECT > Info > Localization의 developement language를 리턴
        //현재 이 앱의 경우 developement language는 en임
        
        //아래코드는 디바이스의 언어 한국어를 가져옴 
        let localeID = Locale.preferredLanguages.first
        let languageCode = (Locale(identifier: localeID!).languageCode)!
        print("plusapps deviceLocale: " + languageCode)
        return languageCode == "ko"
        
        
        //항상 en을 리턴
      // let languageCode = Locale.autoupdatingCurrent.languageCode
       // print("plusapps languageCode: " + languageCode!)
      //  //문자열이 같은지 비교 ==
      //  return languageCode == "ko"
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
