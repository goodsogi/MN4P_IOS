//
//  LanguageManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 2020/12/18.
//  Copyright © 2020 박정규. All rights reserved.
//

import Foundation


class LanguageManager {

public static func getString(key:String) -> String {
    
    if (UserInfoManager.isLanguageKorean()) {
        return getKoreanWord(key: key)
    } else {
        return getEnglishWord(key: key)
    }
}
    
    private static func getKoreanWord(key:String) -> String {
        
        switch key {
        case "recommended":
            return "추천"
        case "main_street":
            return "큰길우선"
        case "no_stairs":
            return "계단제외"
        case "min_distance":
            return "최단거리"
        case "home_is_set":
            return "집이 설정되었습니다."
        case "home":
            return "집"
        case "work":
            return "직장"
        case "work_is_set":
            return "직장이 설정되었습니다."
        case "error_ocurred_set_destination_again":
            return "오류가 발생했습니다. 목적지를 다시 설정해주세요."
        case "hour":
            return "시간"
        case "min":
            return "분"
        case "sec":
            return "초"
        case "kcal":
            return "칼로리"
        case "you_have_arrived":
            return "목적지에 도착했습니다."
        default:
            return ""
        }
    }
    
    private static func getEnglishWord(key:String) -> String {
        
        switch key {
        case "recommended":
            return "Recommended"
        case "main_street":
            return "Main street"
        case "no_stairs":
            return "No stairs"
        case "min_distance":
            return "Min distance"
        case "home_is_set":
            return "Home is set."
        case "home":
            return "Home"
        case "work":
            return "Work"
        case "work_is_set":
            return "Work place is set."
        case "error_ocurred_set_destination_again":
            return "Error occurred. Set destination again."
        case "hour":
            return "hour"
        case "min":
            return "min"
        case "sec":
            return "sec"
        case "kcal":
            return "kcal"
        case "you_have_arrived":
            return "You have arrived."
        default:
            return ""
        }
    }
    
  

}
