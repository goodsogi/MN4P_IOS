//
//  BearingManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 8..
//  Copyright © 2018년 박정규. All rights reserved.
//

import GoogleMaps

class BearingManager {
    static private func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    static private func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }
    
    static public func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
    
    
}
