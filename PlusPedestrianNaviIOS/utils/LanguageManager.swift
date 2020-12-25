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
        case "turn_left":
            return "좌회전"
        case "turn_right":
            return "우회전"
        case "go_straight":
            return "직진"
        case "out_of_route_search_route_again":
            return "경로를 벗어났습니다. 다시 경로를 탐색합니다."
        case "twelve_oclock":
            return "열두시"
        case "three_oclock":
            return "세시"
        case "nine_oclock":
            return "아홉시"
        case "six_oclock":
            return "여섯시"
        case "out_of_route_again_go_back":
            return "다시 경로를 벗어났습니다. 뒤돌아가세요."
        case "kilometers":
            return "킬로미터"
        case "kilometer":
            return "킬로미터"
        case "meters_full_name":
            return "미터"
        case "meter_full_name":
            return "미터"
        case "remaining_distance":
            return "남은거리"
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
        case "turn_left":
            return "turn left"
        case "turn_right":
            return "turn right"
        case "go_straight":
            return "go straight"
        case "out_of_route_search_route_again":
            return "Out of route. Search route again."
        case "twelve_oclock":
            return "12 o\'clock"
        case "three_oclock":
            return "3 o\'clock"
        case "nine_oclock":
            return "9 o\'clock"
        case "six_oclock":
            return "6 o\'clock"
        case "out_of_route_again_go_back":
            return "Out of route again. Go back."
        case "kilometers":
            return "kilometers"
        case "kilometer":
            return "kilometer"
        case "meters_full_name":
            return "meters"
        case "meter_full_name":
            return "meter"
        case "remaining_distance":
            return "remaining distance"
        default:
            return ""
        }
    }
    
    public static func getGeofenceApproachMessage(distanceToGeofenceEnter: String) -> String {
            if (UserInfoManager.isLanguageKorean()) {
                return getKoreanGeofenceApproachMessage(distanceToGeofenceEnter:distanceToGeofenceEnter)
            } else {
                return getEnglishGeofenceApproachMessage(distanceToGeofenceEnter:distanceToGeofenceEnter)
            }
        }
    
    private static func getEnglishGeofenceApproachMessage(distanceToGeofenceEnter: String) -> String{
        let message: String = "Next direction point is " + distanceToGeofenceEnter + " meters ahead.";
            return message;
        }

        private static func getKoreanGeofenceApproachMessage(distanceToGeofenceEnter: String) -> String{
            let message: String = "다음 경로안내는 " + distanceToGeofenceEnter + " 미터 앞입니다.";
            return message;
        }
    
    public static func getNavigationStartMessageForRescan(bearingValue: Double, angleValue: Double) -> String {
        
        var bearingValue2: Double
        if (bearingValue < 0) {
            bearingValue2 = bearingValue + 360
            
        } else {
            bearingValue2 = bearingValue
        }
        

        var directionAngleValue: Double = bearingValue2 - angleValue
        if (directionAngleValue < 0) {
            directionAngleValue = directionAngleValue + 360
            
        }

        
            if (UserInfoManager.isLanguageKorean()) {
                return SOTWFormatter.sharedInstance.format(azimuth: Int(directionAngleValue)) + "출발하세요."
            } else {
                return "Go " + SOTWFormatter.sharedInstance.format(azimuth: Int(directionAngleValue))
            }
        }


}
