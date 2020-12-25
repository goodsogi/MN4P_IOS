//
//  DistanceStringFormatter.swift
//  PlusPedestrianNaviIOS
//
//  Created by Jeonggyu Park on 21/08/2020.
//  Copyright © 2020 박정규. All rights reserved.
//

public class DistanceStringFormatter {

    public static func getFormattedDistanceWithUnit(distance: Int) -> String {
        print("distance: " + String( Float(distance)/Float(1000)))
        if (distance >= 1000) {
            return String(format: "%.2fkm", Float(distance)/Float(1000))
        } else {
            return String(distance) + "m"
        }
    
    }
    
    public static func getFormattedDistance(distance: Int) -> String {
        if (distance >= 1000) {
            return String(format: "%.2f", Float(distance)/Float(1000))
        } else {
            return String(distance)
        }
    
    }
    
    public static func getDistanceUnit(distance: Int) -> String {
            if (distance >= 1000) {
                return "km"
            } else {
                return "m"
            }
        }
}
