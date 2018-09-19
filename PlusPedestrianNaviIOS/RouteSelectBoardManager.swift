//
//  RouteSelectBoardManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 9. 19..
//  Copyright © 2018년 박정규. All rights reserved.
//

import Foundation
import UIKit

class RouteSelectBoardManager {
    
      
    
    func getFormattedTime(time:Int) -> String {
        
        var time: Int = time
        
        if (time < 0) {
            time = 0
        }
        
        let min : Int = time % 3600 / 60
        let hour = time / 3600
        
        var formattedString:String = ""
        
        if(hour > 0) {
            formattedString = hour.description + "시간 "
        }
        
        if(min > 0) {
            formattedString = formattedString + min.description + "분"
        }
        
        if( hour == 0 && min == 0) {
            formattedString = time.description + "초"
        }
        
        return formattedString
        
    }
    
   
    func getFormattedDistance(distance:Int) -> String {
        
        return String(format: "%.2fkm", Double(distance) / Double(1000))
    }
    
    
    
  
    
    func getRouteDetail(geofenceModels: [RoutePointModel]) -> String {
        
        
        let undergroundCount: Int = getRouteUndergroundCount(geofenceModels: geofenceModels)
        let crosswalkCount = getRouteCrosswalkCount(geofenceModels: geofenceModels)
        
        var routeDetail: String = ""
        
        if(undergroundCount > 0) {
            routeDetail = "지하도 " + undergroundCount.description + "회"
        }
        
        if(undergroundCount > 0 && crosswalkCount > 0) {
            routeDetail = routeDetail + "+"
        }
        
        if(crosswalkCount > 0) {
            routeDetail = routeDetail + "횡단보도 " + crosswalkCount.description + "회"
        }
        
        return routeDetail
        
    }
    
    
    func getRouteUndergroundCount(geofenceModels: [RoutePointModel]) -> Int {
        var crosswalkCount:Int = 0
        
        for model in geofenceModels {
            if(model.getDescription()?.contains("지하"))! {
                crosswalkCount = crosswalkCount + 1
            }
            
        }
        
        return crosswalkCount
    }
    
    func getRouteCrosswalkCount(geofenceModels: [RoutePointModel]) -> Int {
        var crosswalkCount:Int = 0
        
        for model in geofenceModels {
            if(model.getDescription()?.contains("횡단"))! {
                crosswalkCount = crosswalkCount + 1
            }
            
        }
        
        return crosswalkCount
    }
    
    
    
    func getCalorie(totalTime: Int) -> String {
        let hour: Int = totalTime / 3600
        let min: Int = (totalTime % 3600) / 60
        let totalMin: Double = Double(hour * 60 + min)
        var totalCalorie: Int = Int((3.3 * 70 * totalMin) / 1000 * 5)
        
        if(totalCalorie == 0) {
            totalCalorie = 1
        }
        
        //TODO: 천단위에 쉼표가 찍히는지 확인하세요
        return String(format: "%dkcal", locale: Locale.current,totalCalorie)
        
        
    }
    
    
    
   
    
    
}
